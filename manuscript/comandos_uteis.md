## Comandos úteis

Seguem alguns comandos úteis e simples abaixo:

-   Remover todos os containers sem uso  
`docker container prune`
-   Parar todos os containers  
`docker stop $(docker ps -q)`
-   Remover todas as imagens locais  
`docker image prune`
-   Remove volumes "órfãos"  
`docker volume prune`
-   Mostra uso de recursos dos containers rodando  
`docker stats $(docker ps --format {{Names}})`
