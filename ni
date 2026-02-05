from sqlmodel import SQLModel, Field
from datetime import datetime
from typing import Optional

class UserActivity(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)

    username: str = Field(index=True)
    userType: int

    action: str = Field(index=True)  
    # examples: LOGIN, LOGOUT, ACCESS_DASHBOARD

    endpoint: Optional[str] = None
    ip_address: Optional[str] = None

    created_at: datetime = Field(default_factory=datetime.utcnow)






@router.post("/token")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    session: DBS.SessionDep,
    request: Request
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

    # 🔹 CREATE ACCESS TOKEN
    access_token_expires = timedelta(
        minutes=Security.ACCESS_TOKEN_EXPIRE_MINUTE
    )

    access_token = Security.create_access_token(
        data={"sub": user.username, "userType": user.userType},
        expires_delta=access_token_expires,
    )

    # 🔹 LOG USER ACTIVITY
    activity = UserActivity(
        username=user.username,
        userType=user.userType,
        action="LOGIN",
        endpoint="/token",
        ip_address=request.client.host
    )

    session.add(activity)
    session.commit()

    return AuthToken.Token(
        access_token=access_token,
        token_type="bearer"
    )




from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from datetime import datetime
from app.schemas.UserActivity import UserActivity
from app.security import Security

class ActivityMiddleware(BaseHTTPMiddleware):

    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)

        try:
            token_data = Security.get_current_user_optional(request)

            if token_data:
                activity = UserActivity(
                    username=token_data.username,
                    userType=token_data.userType,
                    action="ACCESS",
                    endpoint=request.url.path,
                    ip_address=request.client.host,
                )

                session = request.state.db
                session.add(activity)
                session.commit()
        except:
            pass

        return response



app.add_middleware(ActivityMiddleware)



@router.get("/admin/activity")
def get_user_activity(
    admin: Annotated[User.DBUser, Depends(Security.admin_required)],
    session: DBS.SessionDep
):
    statement = select(UserActivity).order_by(
        UserActivity.created_at.desc()
    )

    activities = session.exec(statement).all()

    return [
        {
            "username": a.username,
            "userType": a.userType,
            "action": a.action,
            "endpoint": a.endpoint,
            "ip_address": a.ip_address,
            "time": a.created_at
        }
        for a in activities
    ]