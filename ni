from typing import Annotated
from fastapi import Depends
from fastapi.responses import FileResponse
from sqlmodel import select
from openpyxl import Workbook
import tempfile

@router.get("/admin/export-usernames")
def export_usernames_excel(
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    # Fetch usernames
    statement = select(User.DBUser.username)
    usernames = session.exec(statement).all()

    # Create Excel
    wb = Workbook()
    ws = wb.active
    ws.title = "Usernames"

    ws.append(["Username"])

    for username in usernames:
        ws.append([username])

    # Save temp Excel file
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".xlsx")
    wb.save(temp_file.name)

    return FileResponse(
        path=temp_file.name,
        filename="usernames.xlsx",
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )