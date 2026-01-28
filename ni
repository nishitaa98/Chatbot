from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import socket

app = FastAPI()

SERVER_CONFIG = {
    "X": {"host": "10.0.0.1", "port": 3348},
    "Y": {"host": "10.0.0.2", "port": 13477},
    "12": {"host": "69.33.0.1", "port": 603},
    "0": {"host": "10.0.0.243", "port": 17},
    "K": {"host": "10.241.0.1", "port": 3487},
}

class TellerRequest(BaseModel):
    route: str
    teller_no: str
    group_no: str
    cap_level: str
    user_name: str
    branch_no: str
    user_type: str

def build_message(req: TellerRequest) -> str:
    original = " 0226-..**-2185.. 0030043713716".ljust(200)
    data = list(original)

    data[113:120] = req.teller_no.ljust(7)
    data[120:122] = req.group_no.ljust(2)
    data[122:124] = req.cap_level.ljust(2)
    data[124:137] = req.user_name.ljust(13)
    data[151:156] = req.branch_no.ljust(5)
    data[167:169] = req.user_type.ljust(2)

    return "".join(data)

def send_socket_message(host: str, port: int, message: str) -> str:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(10)
        s.connect((host, port))
        s.sendall(message.encode("utf-8"))
        return s.recv(1024).decode("utf-8")

@app.post("/teller/create")
def create_teller(req: TellerRequest):
    if req.route not in SERVER_CONFIG:
        raise HTTPException(status_code=400, detail="Invalid route")

    server = SERVER_CONFIG[req.route]
    message = build_message(req)

    try:
        response = send_socket_message(
            server["host"],
            server["port"],
            message
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {
        "sent_message": message,
        "server_response": response
    }