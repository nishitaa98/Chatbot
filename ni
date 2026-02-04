from sqlmodel import select
from typing import Optional

@router.put("/admin/users/status")
def enable_disable_user(
    username: str,
    disabled: bool,   # true = disable, false = enable
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    statement = select(User.DBUser).where(User.DBUser.username == username)
    user = session.exec(statement).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.disabled = disabled
    session.add(user)
    session.commit()
    session.refresh(user)

    return {
        "username": user.username,
        "disabled": user.disabled,
        "status": "disabled" if user.disabled else "enabled"
    }