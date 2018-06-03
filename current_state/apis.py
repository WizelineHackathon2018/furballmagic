from itertools import groupby
from pprint import pprint
import json
import os
import requests
import gspread
from oauth2client.service_account import ServiceAccountCredentials
requests.packages.urllib3.disable_warnings()


class SheetsApi(object):

    def __init__(self, file_id, cred_file):
        self._file_id = file_id
        self._client = None
        self._cred_file = cred_file

    def setup_api(self):
        # Setup the Sheets API
        scope = ['https://www.googleapis.com/auth/drive']
        # creds = ServiceAccountCredentials.from_json_keyfile_name(self._cred_file, scope)
        creds = ServiceAccountCredentials.from_json_keyfile_dict(self._cred_file, scope)
        self._client = gspread.authorize(creds)

    def fetch_sheet(self):
        sheet = self._client.open_by_key(self._file_id).sheet1
        return sheet.get_all_records()


class KnowBe4Api(object):
    api_url = None
    _api_token = None

    def __init__(self, api_url, api_token):
        self.api_url = api_url
        self._api_token = api_token

    def _get_k8s_api_headers(self):
        return {
            'Accept': 'application/json',
            'Authorization': f"Bearer {self._api_token}"
        }

    def api_get_groups(self):
        url = f"{self.api_url}/groups"
        res = requests.get(
            url,
            headers=self._get_k8s_api_headers(),
            verify=False)
        return res.json()

    def api_get_group(self, group_id):
        url = f"{self.api_url}/groups/{group_id}"
        res = requests.get(
            url,
            headers=self._get_k8s_api_headers(),
            verify=False)
        return res.json()

    def api_get_group_memebers(self, group_id):
        url = f"{self.api_url}/groups/{group_id}/members"
        res = requests.get(
            url,
            headers=self._get_k8s_api_headers(),
            verify=False)
        return res.json()


class KnowBe4(object):
    _api = None

    def __init__(self, know_be4_api, sheets_api):
        self._api = know_be4_api
        self._sheets_api = sheets_api

    def group_by_name(self, name):
        groups = self._api.api_get_groups()
        return list(filter(lambda x: x['name'] == name, groups))

    def group_members(self, name):
        group = self.group_by_name(name)
        if not group:
            return []
        group_id = group[0]['id']
        return self._api.api_get_group_memebers(group_id)

    def get_staff_members(self):
        self._sheets_api.setup_api()
        return self._sheets_api.fetch_sheet()

    @classmethod
    def group_staff_by_project(cls, members):
        # members = self.get_staff_members()
        members.sort(key=lambda x: x['Project'])
        return {k: list(v) for k, v in groupby(members, key=lambda x: x['Project'])}

    @classmethod
    def member_has_completed_training(cls, member, completed_list):
        return member in completed_list

    def get_memebrs_in_completed(self):
        return self.group_members("Q2 - 2018 Completed Training")

    def get_members_w_status(self):
        completed_list = list(map(
            lambda x: x['email'],
            self.get_memebrs_in_completed()))
        members = self.get_staff_members()
        for member in members:
            member['complete'] = False
            if self.member_has_completed_training(member['Email'], completed_list):
                member['complete'] = True
        return self.group_staff_by_project(members)

def main():
    api_url = os.environ['API_URL']
    token = os.environ['API_TOKEN']
    file_id = os.environ['GSHEETS_FILE_ID']
    gsheets_sa = json.loads(os.environ['GSHEETS_SA'])

    kb4_api = KnowBe4Api(api_url, token)
    s_api = SheetsApi(file_id, gsheets_sa)
    kb4 = KnowBe4(kb4_api, s_api)

    # pprint(kb4_api.api_get_groups())
    # pprint(kb4.group_by_name("Q2 - 2018 Completed Training"))
    # pprint(kb4.group_members("Q2 - 2018 Completed Training"))
    # pprint(kb4.api_get_group("588463"))
    # pprint(kb4.get_staff_members())
    # pprint(kb4.group_members("Q2 - 2018 Completed Training"))
    # pprint(kb4.get_memebrs_in_completed())
    # pprint(kb4.group_staff_by_project())
    json_str = json.dumps(kb4.get_members_w_status(), indent=2)
    print(json_str)


def lambda_handler(event=None, context=None):
    main()

if __name__ == "__main__":
    main()
