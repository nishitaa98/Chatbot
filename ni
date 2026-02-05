from fastapi import Request

@router.post("/token")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    db: DBS.SessionDep,
    request: Request
) -> AuthToken.Token:

    user = Security.authenticate_user(
        form_data.username,
        form_data.password,
        db
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(
        minutes=Security.ACCESS_TOKEN_EXPIRE_MINUTES
    )

    access_token = Security.create_access_token(
        data={"sub": user.username, "userType": user.userType},
        expires_delta=access_token_expires
    )

    # ✅ ACTIVITY LOG (FIXED)
    activity = UserActivity(
        username=user.username,
        userType=user.userType,
        action="LOGIN",
        endpoint="/token",
        ip_address=request.client.host
    )

    db.add(activity)
    db.commit()

    return AuthToken.Token(
        access_token=access_token,
        token_type="bearer"
    )