from typing import List
from sqlmodel import select

@router.get("/admin/users")
def get_all_users(
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    statement = select(User.DBUser)
    users = session.exec(statement).all()

    return [
        {
            "username": user.username,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "departmentCode": user.departmentCode,
            "userType": user.userType,
            "role": "admin" if user.userType == 1 else "user"
        }
        for user in users
    ]