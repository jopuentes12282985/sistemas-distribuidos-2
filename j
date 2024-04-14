import socket
import threading
import json
import logging

class Server:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.data = {
            "1234567890": {"nombre": "Juan", "direccion": "Calle 123", "ciudad": "Ciudad A"},
            "9876543210": {"nombre": "María", "direccion": "Calle 456", "ciudad": "Ciudad B"}
        }
        self.logger = logging.getLogger(__name__)

    def handle_client(self, client_socket, address):
        self.logger.info('Conexión establecida por %s', address)
        try:
            data = client_socket.recv(1024).decode()
            if data in self.data:
                info = self.data[data]
                response = json.dumps({"nombre": info['nombre'], "direccion": info['direccion'], "ciudad": info['ciudad']})
            else:
                response = json.dumps({"error": "Persona dueña de ese número telefónico no existe."})
            client_socket.sendall(response.encode())
        except Exception as e:
            self.logger.error("Error al manejar la solicitud: %s", e)
        finally:
            client_socket.close()

    def start(self):
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
                server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                server_socket.bind((self.host, self.port))
                server_socket.listen()

                self.logger.info("Servidor escuchando en todas las interfaces en el puerto %s", self.port)

                while True:
                    conn, addr = server_socket.accept()
                    threading.Thread(target=self.handle_client, args=(conn, addr)).start()
        except KeyboardInterrupt:
            self.logger.info("Servidor detenido manualmente.")

def main():
    logging.basicConfig(level=logging.INFO)
    config = {
        "host": '',  # Escucha en todas las interfaces de red
        "port": 65432
    }

    server = Server(config["host"], config["port"])
    server.start()

if __name__ == "__main__":
    main()
