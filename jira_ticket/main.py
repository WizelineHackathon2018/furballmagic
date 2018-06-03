from jira import JIRA
import os
import json
import traceback
from pprint import pprint
import urllib3

urllib3.disable_warnings()


def response(message, status_code):
    """Build a response for api-gateway"""
    return {
        'statusCode': str(status_code),
        'body': json.dumps(message),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
            },
        }

def create_issue(summary, description, assignee):
    jira_server = os.environ['JIRA_URL']
    jira_user = os.environ['JIRA_USER']
    jira_pass = os.environ['JIRA_PASS']

    jira = JIRA(jira_server, auth=(jira_user, jira_pass))
    issue_dict = {
        'project': {'key': "AS"},
        'summary': summary,
        'description': description,
        'issuetype': {'name': 'Task'},
        'assignee': {
            'name': assignee.replace("@wizeline.com", "")
        }
    }
    return jira.create_issue(fields=issue_dict)


def handler(event=None, context=None):
    """Handler for the lambda function."""
    print(event)
    body = json.loads(event['body'])
    try:
        new_issue = create_issue(
            body['summary'],
            body['description'],
            body['assignee'])
        red_dict = vars(new_issue)
        red_dict['_session'] = None
        red_dict['fields'] = None

        return response(red_dict, 200)
    except Exception as e:
        traceback.print_exc()
        return response({'error': f"{e}, {traceback.format_exc()}"}, 500)

if __name__ == "__main__":
    new_issue = create_issue(
        "New issue from jira-python2",
        "New issue from jira-python",
        "saul.ortigoza")
    pprint(vars(new_issue))
