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

    # ✅ STORE LOGIN LOG (ADMIN + USER)
    login_log = UserLoginLog(
        username=user.username,
        userType=user.userType,              # 1 = admin, 3 = user
        role="admin" if user.userType == 1 else "user"
    )
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

from sqlmodel import SQLModel, Field
from datetime import datetime

class UserLoginLog(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    username: str = Field(nullable=False)
    userType: int = Field(nullable=False)
    role: str = Field(nullable=False)
    login_time: datetime = Field(default_factory=datetime.utcnow)




from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import select

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.get("/login-logs/{username}")
def get_user_login_logs(
    username: str,
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    logs = session.exec(
        select(UserLoginLog)
        .where(UserLoginLog.username == username)
        .order_by(UserLoginLog.login_time.desc())
    ).all()

    if not logs:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No login logs found for this user"
        )

    return {
        "requested_user": username,
        "total_logins": len(logs),
        "logs": logs
    }



from sqlmodel import SQLModel, Field
from datetime import datetime

class UserLoginLog(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)  # ✅ REQUIRED

    username: str = Field(index=True, nullable=False)
    userType: int = Field(nullable=False)   # 1=admin, 3=user
    login_time: datetime = Field(default_factory=datetime.utcnow)

