#include <stdio.h>
#include <sys/socket.h>
#include <netdb.h>

int main(int argc, char *argv[]){
    int mySocket;
    int connection;
    int port;
    int initial = 0;
    int final = 0;
    char *destine;
    destine = argv[1];

    struct sockaddr_in alvo;

    print("Define the number of verification port that have to verify: ");
    scanf("%d", final);

    for(port=initial; port<final; port++){

        mySocket = socket(AF_INET, SOCK_STREAM,0);
        alvo.sin_family = AF_INET;
        alvo.sin_port = htons(port);
        alvo.sin_addr.s_addr = inet_addr(destine);

        connection = connect(mySocket, (struct sockaddr *) &alvo, sizeof alvo);

        if (connection == 0){
            printf("Open port: %d\n", port);
            close(mySocket);
            close(connection);
        }

        else {
            close(mySocket);
            close(connection);
        }
    }
}
