import unittest, subprocess, os
from pathlib import Path
class Contracts(unittest.TestCase):
    def test_missing_key_fails_before_curl(self):
        env=dict(os.environ);env.pop("MRPC_API_KEY",None)
        result=subprocess.run(["bash","examples/quickstart.sh"],env=env,capture_output=True,text=True)
        self.assertNotEqual(result.returncode,0)
        self.assertIn("MRPC_API_KEY",result.stderr)
    def test_trial_key_fails(self):
        result=subprocess.run(["bash","examples/quickstart.sh"],env={**os.environ,"MRPC_API_KEY":"TRIAL"},capture_output=True,text=True)
        self.assertNotEqual(result.returncode,0)
    def test_examples_authenticate_and_are_read_only(self):
        for name in ["quickstart.sh","quickstart.ps1"]:
            text=Path("examples",name).read_text()
            self.assertIn("ApiKey",text);self.assertIn("UserCopiers",text)
            self.assertNotIn("OrderSend",text);self.assertNotIn("DemoAccount/Open",text)
