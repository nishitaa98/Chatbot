from fastapi import FastAPI, HTTPException
import socket

app = FastAPI()

@app.post("/depositclosure")
def tellerr(data: acctransfer):

    # -------- MESSAGE BUILDER --------
    def build_message(req: acctransfer) -> str:
        # 253-length raw message
        message = (
            "003004372251011451001010086"
            + " " * (253 - len("003004372251011451001010086"))
        )

        data_list = list(message)

        # replace fixed positions
        data_list[139:150] = req.from_acc.ljust(11)
        data_list[169:183] = req.amt.zfill(14)

        updated_message = "".join(data_list)
        print(updated_message)

        return updated_message

    # -------- SERVER CONFIG --------
    server_key = data.server.upper()

    if server_key not in SERVER_CONFIG:
        raise HTTPException(status_code=409, detail="Invalid server type")

    server = SERVER_CONFIG[server_key]

    # ✅ build updated message directly
    final_message = build_message(data)

    # -------- SOCKET CALL --------
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
            client_socket.settimeout(10)
            client_socket.connect((server["host"], server["port"]))
            client_socket.sendall(final_message.encode("utf-8"))

            response = client_socket.recv(1024).decode("utf-8")
            print(response)

            return {
                "region": server_key,
                "from_acc": data.from_acc,
                "amount": data.amt,
                "server_response": response
            }

    except socket.timeout:
        raise HTTPException(status_code=504, detail="Socket timeout")