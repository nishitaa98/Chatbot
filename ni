@router.get("/admin/login-logs/{username}")
def get_login_logs(
    username: str,
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    logs = session.exec(
        select(UserLoginLog)
        .where(UserLoginLog.username == username)
        .order_by(UserLoginLog.login_time.desc())
    ).all()

    return logs