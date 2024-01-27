from DataModel.Model import Model
import re
import pytest
from xml.sax.saxutils import escape

from Controller.StatusHelper import StatusHelper

#List out the keywords that will appear in a nohup error message
log_errors = [
    "ERROR"
]

# Make a regex that matches if any of our regexes match.
combined = "(" + ")|(".join(log_errors) + ")"


def check_for_errors(logfile, record_property):
    with open(logfile, "r") as f:
        pattern = re.compile(combined, re.IGNORECASE)
        line_no = 1
        errors = False

        for line in f:
            if pattern.search(line) is not None:
                print(line)
                print(f'pattern={pattern}')
                record_property("ERROR", escape(f"{logfile}, {line_no}, \"{line.strip().replace(',', ' ')}\""))
                errors = True

            line_no += 1

        return errors

def test_ctuslog_contains_no_errors(record_property):
    """
    Tests that p2/CTSmodel.log file does not contain any error messages
    """
    h = StatusHelper()
    h.skip_test(h.get_status('test_ctuslog_contains_no_errors'))

    if not Model.getInstance().files.parnems:
        pytest.skip("Must be Parallel run to run this test.")

    # need to check the file existence in case the CTUS model gets turned off
    try:
        ctuslog_file = Model.getInstance().files.p2.ctuslog.path
        print(ctuslog_file)
    except AttributeError:
        record_property("csv_header", "Log File, Line #, Message")
        record_property("ERROR", "none,none,p2/CTSmodel.log does not exist. Pls make sure CTUS is on in the scedes file.")
        assert False

    record_property("csv_header", "Log File, Line #, Message")
    errors = False

    if check_for_errors(Model.getInstance().files.p2.ctuslog.path, record_property):
        errors = True

    assert not errors