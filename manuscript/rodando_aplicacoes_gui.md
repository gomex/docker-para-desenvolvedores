## Posso rodar aplicações GUI?
Com certeza, é plenamente possível rodar aplicações GUI em contêineres, o que significa que todas as vantagens de utilizar o Docker se aplicam também às aplicações gráficas.

Além disso é possível fazer a aplicação funcionar em múltiplos sistemas (Linux, Windows e macOS) apenas construindo ela para Linux.

### Como?
Antes de mais nada... Em 99% dos casos é preciso liberar o acesso ao X: `xhost local` (essa liberação ficará vigente até desligar/reiniciar o host)

Comando mais simples o possível, monta o socket X11 do host no contêiner e define o display (note que vamos "evoluindo" o comando aos poucos, mas pode usar apenas as flags que achar necessário - as únicas obrigatórias são a montagem de volume do `/tmp/.X11-unix` e a variável de ambiente `DISPLAY`):

```
docker container run [--rm [-it]|-d] \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY \
imagem [comando]
```
Em alguns casos a variável `DISPLAY` tem de ser `DISPLAY=unix$DISPLAY` (mas pra ser sincero até agora eu não sei bem o motivo, somente que era o indicado pela pessoa que fez a imagem).


Para utilizar o suporte a aceleração 3D por hardware:

```
docker container run [--rm [-it]|-d] \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY \
--device /dev/dri \
imagem [comando]
```

Adicionando audio:

```
docker container run [--rm [-it]|-d] \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY \
--device /dev/dri \
--device /dev/snd \
imagem [comando]
```

Adicionando webcam:

```
docker container run [--rm [-it]|-d] \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY \
--device /dev/dri \
--device /dev/snd \
--device /dev/video0 \
imagem [comando]
```

Usando a mesma data/hora do host:

```
docker container run [--rm [-it]|-d] \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY \
--device /dev/dri \
--device /dev/snd \
--device /dev/video0 \
-v /etc/localtime:/etc/localtime:ro \
imagem [comando]
```
Atenção: dependendo da distribuição, não há um /etc/localtime, tem de averiguar como ela define o timezone e "replicar" no contêiner.

Mantendo as configurações do aplicativo:

```
docker container run [--rm [-it]|-d] \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY \
--device /dev/dri \
--device /dev/snd \
--device /dev/video0 \
-v /etc/localtime:/etc/localtime:ro \
-v $HOME/.config/app:/root/.config/app \
imagem [comando]
```
Obs: o caminho é apenas um exemplo.

**Bônus:** Controle do video-game (na verdade qualquer dispositivo de entrada):

```
docker container run [--rm [-it]|-d] \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY \
--device /dev/dri \
--device /dev/snd \
--device /dev/video0 \
-v /etc/localtime:/etc/localtime:ro \
-v $HOME/.config/app:/root/.config/app \
--device /dev/input \
imagem [comando]
```

### E o docker-compose?
Funciona normalmente... Basta montar o socket X11 e definir a variável de ambiente no docker-compose.yml e será possível iniciar múltiplos aplicativos com apenas um comando.

### No Windows e macOS

#### [Mac OS X](https://github.com/docker/docker/issues/8710#issuecomment-71113263)  
Instalar o Docker for Mac

```
brew install socat
brew cask install xquartz
open -a XQuartz

socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"
docker container run -e DISPLAY=hostip:0 [...] image OU DISPLAY=hostip:0 docker-compose up [-d]
```  
#### [Windows](https://github.com/docker/docker/issues/8710#issuecomment-135109677)  
Instalar o xming  
Instalar o Docker for Windows

```
xming :0 -ac -clipboard -multiwindow
docker container run -e DISPLAY=hostip:0 [...] image OU DISPLAY=hostip:0 docker-compose up [-d]
```
