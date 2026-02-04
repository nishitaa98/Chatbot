# app/models/user_logs.py
from sqlmodel import SQLModel, Field
from datetime import datetime

class UserStatusLog(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    username: str = Field(nullable=False)
    action: str = Field(nullable=False)        # ENABLED / DISABLED
    changed_by: str = Field(nullable=False)
    timestamp: datetime = Field(default_factory=datetime.utcnow)



from sqlmodel import select
from datetime import datetime

@router.put("/admin/users/status")
def enable_disable_user_with_log(
    username: str,
    disabled: bool,
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    user = session.exec(
        select(User.DBUser).where(User.DBUser.username == username)
    ).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update user status
    user.disabled = disabled
    session.add(user)

    # Create log entry
    log = UserStatusLog(
        username=user.username,
        action="DISABLED" if disabled else "ENABLED",
        changed_by=admin.username,
        timestamp=datetime.utcnow()
    )
    session.add(log)

    session.commit()

    return {
        "username": user.username,
        "status": "disabled" if user.disabled else "enabled",
        "changed_by": admin.username,
        "timestamp": log.timestamp.isoformat(),
        "logged": True
    }


