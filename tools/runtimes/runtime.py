'''
    runtime.py
'''

class Runtime:
    '''
        Data class for holding information provided by a runtime
    '''

    # Holds the git branch the runtime occured on
    branch = ""

    # Holds the error message
    message = ""

    # Holds the filename where the error occured
    file = ""

    # Holds the line number where the error occured
    line = ""

    # Holds the extended description of the issue (usually the stack trace)
    desc = ""

    # Format for the title of the issue
    # 0 - Error message
    # 1 - File where the error occured
    # 2 - Line number where the error occured
    # 3 - Branch the error occured on
    issue_title_template = "{0} - {1}@{2} (on {3})"

    # Format for the body of the issue
    # 0 - Branch the error occured on
    # 1 - Error message
    # 2 - File where the error occured
    # 3 - Line number where the error occured
    # 4 - Full runtime details (the stack trace)
    issue_body_template = "**Branch:** {0}\n\n**Error message:** {1}\n\n**Where:** {2}, line {3}\n\n**Stack trace:**\n```\n{4}\n```"

    def __init__(self, message, file, line, desc):
        self.message = message
        self.file = file
        self.line = line
        self.desc = desc.replace(";", "\n")

    def set_branch(self, branch):
        self.branch = branch

    def get_msg(self):
        '''
            :return message: The error message of this runtime
        '''

        return self.message

    def get_file(self):
        '''
            :return filename: The file name where the runtime occured
        '''

        return self.file

    def get_line(self):
        '''
            :return line: The line number where the runtime occured
        '''

        return self.line

    def get_desc(self):
        '''
            :return desc: The extended description of the runtime
        '''

        return self.desc

    def get_title(self):
        '''
            :return title: A formatted issue title for the runtime
        '''

        return self.issue_title_template.format(self.message, self.file, self.line, self.branch)

    def get_body(self):
        '''
            :return body: A formatted issue body for the runtime
        '''

        return self.issue_body_template.format(self.branch, self.message, self.file, self.line, self.desc)
