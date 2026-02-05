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






@router.get("/admin/users/{username}")
def get_user_by_username(
    username: str,
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    statement = select(User.DBUser).where(User.DBUser.username == username)
    user = session.exec(statement).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "username": user.username,
        "firstName": user.firstName,
        "lastName": user.lastName,
        "departmentCode": user.departmentCode,
        "userType": user.userType
    }