@router.post("/token")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    session: DBS.SessionDep
):
    user = Security.authenticate_user(
        form_data.username,
        form_data.password,
        session
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if user.disabled:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is disabled"
        )

    # ✅ LOGIN LOG (NO EXTRA FIELDS)
    session.add(
        UserLoginLog(
            username=user.username,
            userType=user.userType
        )
    )
    session.commit()   # 🔴 REQUIRED

    # ✅ TOKEN
    access_token = Security.create_access_token(
        data={"sub": user.username}
    )

    return {
        "access_token": access_token,
        "token_type": "bearer"
    }