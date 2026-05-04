import socket
from fastapi import HTTPException

def chequebookenq(data: RequestData):

    server_key = data.server.upper()

    if server_key not in SERVER_CONFIG:
        raise HTTPException(status_code=400, detail="Invalid server type")

    server = SERVER_CONFIG[server_key]

    try:
        # Prepare message
        message = BASE_MESSAGE.replace("OLD_ACC", data.acc)
        print("Final Message:", message)

        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
            client_socket.settimeout(10)

            # Connect
            client_socket.connect((server["host"], server["port"]))

            # Send
            client_socket.sendall(message.encode("utf-8"))

            # ✅ Receive full response (1269)
            expected_length = 1269
            response = b""

            while len(response) < expected_length:
                chunk = client_socket.recv(1024)
                if not chunk:
                    break
                response += chunk

            # Decode AFTER full receive
            response_text = response.decode("utf-8", errors="ignore")

            print("Full Response:", response_text)
            print("Length:", len(response))

            # Extract safely
            extracted = response_text[149:185] if len(response_text) >= 185 else None

            return {
                "server": server_key,
                "final_message": message,
                "server_response": response_text,
                "extracted": extracted
            }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))