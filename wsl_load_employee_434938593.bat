setlocal enabledelayedexpansion
sqlcmd -S DESKTOP-93CSLII\SQLEXPRESS -E -d PYDB -i "wsl_load_employee_434938593.ctl" -o "wsl_load_employee_434938593.load.log"