from typing import Annotated
from fastapi import Depends, HTTPException, APIRouter
from sqlmodel import select

router = APIRouter()

@router.get("/admin/users/{username}")
def get_user_with_logs(
    username: str,
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    # 1️⃣ Get user details
    user_stmt = select(User.DBUser).where(User.DBUser.username == username)
    user = session.exec(user_stmt).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # 2️⃣ Get login logs for that user
    logs_stmt = (
        select(User.UserActivity)
        .where(User.UserActivity.username == username)
        .order_by(User.UserActivity.created_at.desc())
    )

    logs = session.exec(logs_stmt).all()

    # 3️⃣ Response
    return {
        "user": {
            "username": user.username,
            "firstName": user.firstname,
            "lastName": user.lastname,
            "departmentCode": user.departmentCode,
            "userType": user.userType
        },
        "login_logs": [
            {
                "username": log.username,
                "login_time": log.created_at.isoformat()
            }
            for log in logs
        ]
    }