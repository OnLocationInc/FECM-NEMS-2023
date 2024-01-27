from DataModel.Model import Model
import re
from xml.sax.saxutils import escape

from Controller.StatusHelper import StatusHelper

#List out the keywords that will appear in a nohup error message
nohup_errors = [
    "ERROR",
    "ABORTED",
    "No retrieve",
    "This is a very bad Thing",
    "Turning Xpresssw off",
    "not loaded",
    "AIMMS license issue.  Will retry. Number of tries so far:  9"
]

infeas_errors = [
    "INFEAS"
]

# Make a regex that matches if any of our regexes match.
combined = "(" + ")|(".join(nohup_errors) + ")"
combined_infeas = "(" + ")|(".join(infeas_errors) + ")"

def check_for_errors(nohup, record_property):
    with open(nohup, "r") as f:
        pattern = re.compile(combined, re.IGNORECASE)
        line_no = 1
        errors = False

        for line in f:
            if pattern.search(line) is not None:
                sub = 'AIMMS Exited early. Likely a licensing issue or error in the AIMMS code or transfer data. Displaying log/messages.log:'
                sub2 = 'error: Could not find CPLEX 12.10 license file supplied by AIMMS.'
                s = line.strip().replace(',', ' ')
                if (sub not in s) and (sub2 not in s):
                    record_property("ERROR", escape(f"{nohup}, {line_no}, \"{line.strip().replace(',', ' ')}\""))
                    errors = True
            line_no += 1

        return errors


def check_for_infeas(nohup, record_property):
    with open(nohup, "r") as f:
        pattern = re.compile(combined_infeas, re.IGNORECASE)
        line_no = 1
        errors = False

        for line in f:
            if pattern.search(line) is not None:
                record_property("ERROR", escape(f"{nohup}, {line_no}, \"{line.strip().replace(',', ' ')}\""))
                errors = True
            line_no += 1

        return errors


def get_gpa_from_nohup(nohup):
    """
    returns array of length 2
    first element is final US gpa
    second element is final Regional gpa
    """

    gpa_pattern = r'[0-4]\.[0-9]+'
    #gpa_string_pattern = "GPA.*on a 4 point scale"
    gpa_string_pattern = "GPA \(.*\)"
    pattern = re.compile(gpa_string_pattern, re.IGNORECASE)

    with open(nohup, "r") as f:
        final_gpa_string = pattern.findall(f.read()) or ['ERROR 0.0 ERROR 0.0']

    final_gpa_string = final_gpa_string[-1]

    return [float(i) for i in re.findall(gpa_pattern, final_gpa_string)]


def test_nohup_contains_no_errors(record_property):
    """
    Tests that Nohup.out files do not contain any error messages
    """
    h = StatusHelper()
    h.skip_test(h.get_status('test_nohup_contains_no_errors'))

    files = Model.getInstance().files
    nohups =[]
    nohups.append(files.nohup.path)

    if files.parnems:
        nohups.append(files.p1.nohup.path)
        nohups.append(files.p2.nohup.path)
        nohups.append(files.p3.nohup.path)

    record_property("csv_header", "Nohup File, Line #, Message")
    errors = False

    for n in nohups:
        if check_for_errors(n, record_property):
            errors = True

    assert not errors


def test_nohup_contains_no_infeas(record_property):
    """
    Tests that Nohup.out files do not contain any "ECP INFEASIBILITY PROGRESS REPORT :  Xpress depress :" or "EFD INFEASIBILITY PROGRESS REPORT" messages
    """
    h = StatusHelper()
    h.skip_test(h.get_status('test_nohup_contains_no_infeas'))

    files = Model.getInstance().files
    nohups =[]
    nohups.append(files.nohup.path)

    if files.parnems:
        nohups.append(files.p1.nohup.path)
        nohups.append(files.p2.nohup.path)
        nohups.append(files.p3.nohup.path)

    record_property("csv_header", "Nohup File, Line #, Message")
    errors = False

    for n in nohups:
        if check_for_infeas(n, record_property):
            errors = True

    assert not errors


# This test need more preventive code. In corner cases, it throws an empty unformated .cvs file and makes Validator_FAIL.xlsx not open.
def test_convergence(record_property):
    """
    Is the final cycle gpa >= 3.50
    """
    h = StatusHelper()
    h.skip_test(h.get_status('test_convergence'))

    nohup = Model.getInstance().files.nohup.path
    [US_gpa, REG_gpa] = get_gpa_from_nohup(nohup)

    record_property("csv_header", "GPA Type, GPA value")
    errors = False

    if US_gpa == 0 and REG_gpa == 0:
        record_property("ERROR", r"No GPA found, 0.0")
        errors = True
    else:

        if US_gpa < 3.5:
            record_property("ERROR", f"US, {US_gpa}")
            errors = True

        if REG_gpa < 3.5:
            record_property("ERROR", f"REG, {REG_gpa}")
            errors = True

    assert not errors