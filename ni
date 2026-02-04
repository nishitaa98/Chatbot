@router.post("/token")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    session: DBS.SessionDep
):
    user = Security.authenticate_user(
        form_data.username, form_data.password, session
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # ✅ LOGIN LOG
    login_log = UserLoginLog(username=user.username)
    session.add(login_log)
    session.commit()

    access_token_expires = timedelta(
        minutes=Security.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    access_token = Security.create_access_token(
        data={"sub": user.username},
        expires_delta=access_token_expires
    )

    return AuthToken.Token(
        access_token=access_token,
        token_type="bearer"
    )