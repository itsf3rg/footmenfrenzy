import socket
import json
import sys

def send_command(cmd_dict):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(2.0)
        s.connect(('127.0.0.1', 8081))
        # Send JSON with newline
        msg = json.dumps(cmd_dict) + "\n"
        s.sendall(msg.encode('utf-8'))
        
        # Receive all data until connection closed
        resp = b""
        while True:
            chunk = s.recv(4096)
            if not chunk:
                break
            resp += chunk
            
        s.close()
        return resp.decode('utf-8')
    except Exception as e:
        return json.dumps({"status": "error", "message": str(e)})

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd_str = sys.argv[1]
        try:
            cmd = json.loads(cmd_str)
            print(send_command(cmd))
        except Exception as e:
            print(json.dumps({"status": "error", "message": "Invalid JSON argument"}))
    else:
        print(json.dumps({"status": "error", "message": "No command provided"}))
