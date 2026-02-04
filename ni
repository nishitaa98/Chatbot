from sqlmodel import select

@router.get("/admin/login-logs")
def get_login_logs(
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    logs = session.exec(
        select(UserLoginLog).order_by(UserLoginLog.login_time.desc())
    ).all()

    return [
        {
            "username": log.username,
            "login_time": log.login_time.isoformat()
        }
        for log in logs
    ]