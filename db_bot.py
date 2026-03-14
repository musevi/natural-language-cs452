import json
from openai import OpenAI
import os
import re
import sqlite3
from time import time

print("Running db_bot.py!")

fdir = os.path.dirname(__file__)
def getPath(fname):
    return os.path.join(fdir, fname)

# SQLITE
sqliteDbPath = getPath("aidb.sqlite")
setupSqlPath = getPath("setup_sqlite.sql")
setupSqlDataPath = getPath("setupData_sqlite.sql")

if os.path.exists(sqliteDbPath):
    os.remove(sqliteDbPath)

sqliteCon = sqlite3.connect(sqliteDbPath)
# enable foreign key enforcement in SQLite
sqliteCon.execute("PRAGMA foreign_keys = ON;")
sqliteCursor = sqliteCon.cursor()

with (
        open(setupSqlPath) as setupSqlFile,
        open(setupSqlDataPath) as setupSqlDataFile
    ):

    setupSqlScript = setupSqlFile.read()
    setupSQlDataScript = setupSqlDataFile.read()

# execute setup files
sqliteCursor.executescript(setupSqlScript)
sqliteCursor.executescript(setupSQlDataScript)

def build_schema_summary(script, max_columns=5):
    summary_parts = []
    for match in re.finditer(r"create table\s+([^\s(]+)\s*\((.*?)\);", script, flags=re.IGNORECASE | re.S):
        table_name = match.group(1)
        columns_block = match.group(2)
        column_names = []
        for line in columns_block.splitlines():
            line = line.strip()
            if not line or line.startswith("--"):
                continue
            if line.lower().startswith("primary key") or line.lower().startswith("foreign key"):
                continue
            column_name = line.split()[0].rstrip(",")
            column_names.append(column_name)
        if column_names:
            display_columns = column_names[:max_columns]
            if len(column_names) > max_columns:
                display_columns.append("...")
            summary_parts.append(f"{table_name}({', '.join(display_columns)})")
    return "; ".join(summary_parts) if summary_parts else "schema unavailable"

schema_summary = build_schema_summary(setupSqlScript)

def runSql(query):
    result = sqliteCursor.execute(query).fetchall()
    return result

# OPENAI
configPath = getPath("config.json")
print(configPath)
with open(configPath) as configFile:
    config = json.load(configFile)

openAiClient = OpenAI(api_key = config["openaiKey"])
openAiClient.models.list()
chosen_model = "gpt-4o"

def getChatGptResponse(content):
    stream = openAiClient.chat.completions.create(
        model=chosen_model,
        messages=[{"role": "user", "content": content}],
        stream=True,
    )

    responseList = []
    for chunk in stream:
        if chunk.choices[0].delta.content is not None:
            responseList.append(chunk.choices[0].delta.content)

    result = "".join(responseList)
    return result


# strategies
commonSqlOnlyRequest = " Give me a sqlite select statement that answers the question using the guitar teacher schema. Only respond with sqlite syntax. If there is an error do not explain it!"
strategies = {
    "zero_shot": setupSqlScript + commonSqlOnlyRequest,
    "single_domain_double_shot": (
        setupSqlScript
        + " What students are enrolled but do not have phone numbers yet?\n"
        + "\nSELECT s.name, s.email, s.skill_level\nFROM student s\nWHERE s.phone IS NULL;\n "
        + "Which packages are about to expire in the next 30 days?\n"
        + "\nSELECT sp.id, s.name, sp.expires_at, p.name AS package_name\nFROM student_package sp\nJOIN student s ON sp.student_id = s.id\nJOIN package p ON sp.package_id = p.id\nWHERE sp.expires_at BETWEEN date('now') AND date('now', '+30 days');\n "
        + commonSqlOnlyRequest
    )
}

questions = [
    "Which students have lessons scheduled in the next 7 days?",
    "Which students have unpaid invoices and how much is outstanding for each?",
    "Who is missing a phone number in their profile?",
    "What lessons in the last month were marked as no-show?",
]


# use the markdown for the sql syntax to find the SQL query
def sanitizeForJustSql(value):
    gptStartSqlMarker = "```"
    gptEndSqlMarker = "```"
    if gptStartSqlMarker in value:
        value = value.split(gptStartSqlMarker, 1)[1]
        newline_index = value.find("\n")
        if newline_index != -1:
            value = value[newline_index + 1:]
    if gptEndSqlMarker in value:
        value = value.split(gptEndSqlMarker, 1)[0]

    return value.strip()

for strategy in strategies:
    responses = {"strategy": strategy, "prompt_prefix": strategies[strategy]}
    questionResults = []
    print("########################################################################")
    print(f"Running strategy: {strategy}")
    for question in questions:

        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        print("Question:")
        print(question)
        error = "None"
        try:
            getSqlFromQuestionEngineeredPrompt = strategies[strategy] + " " + question
            sqlSyntaxResponse = getChatGptResponse(getSqlFromQuestionEngineeredPrompt)
            sqlSyntaxResponse = sanitizeForJustSql(sqlSyntaxResponse)
            print("SQL Syntax Response:")
            print(sqlSyntaxResponse)
            queryRawResponse = str(runSql(sqlSyntaxResponse))
            print("Query Raw Response:")
            print(queryRawResponse)

            friendlyResultsPrompt = (
                f"I asked: \"{question}\". "
                f"The SQL I executed was: {sqlSyntaxResponse}. "
                f"The raw database response was: {queryRawResponse}. "
                f"Schema summary: {schema_summary}. "
                "Please give a concise, friendly answer without additional suggestions."
            )
            friendlyResponse = getChatGptResponse(friendlyResultsPrompt)
            print("Friendly Response:")
            print(friendlyResponse)
        except Exception as err:
            error = str(err)
            print(err)

        questionResults.append({
            "question": question,
            "sql": sqlSyntaxResponse,
            "queryRawResponse": queryRawResponse,
            "friendlyResponse": friendlyResponse,
            "error": error
        })

    responses["questionResults"] = questionResults

    with open(getPath(f"response_{strategy}_{time()}.json"), "w") as outFile:
        json.dump(responses, outFile, indent = 2)


sqliteCursor.close()
sqliteCon.close()
print("Done!")
