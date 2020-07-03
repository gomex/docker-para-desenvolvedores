# Dockerhub

Você está aprendendo a fazer algo muito legal ao criar a sua própria imagem, que tal compartilhar com as outras pessoas o que você está fazendo? Isso pode ser bem útil para você no futuro e é assim que comunidades fortes são estabelecidas. É pra isso que existe o **Dockerhub**.

#### O que é Dockerhub?

Dockerhub é um repositório compartilhado de imagens Docker. No capítulo anterior você leu um pouco sobre imagens oficiais e não-oficiais, é no Dockerhub que os **Dockerfiles** são disponibilizados para a comunidade com o objetivo de facilitar a construção do seu ambiente Docker.

Diversas empresas disponibilizam suas imagens oficiais na plataforma, como:

+ [MySQL](https://hub.docker.com/_/mysql/)
+ [Nginx](https://hub.docker.com/_/nginx/)
+ [Python](https://hub.docker.com/_/python/)
+ [Node](https://hub.docker.com/_/node/)
+ [WordPress](https://hub.docker.com/_/wordpress/)

Você pode explorar a [lista completa](https://hub.docker.com/explore/) por sua conta.

#### Criando sua conta e um repositório

Agora que você está interessado, vamos criar uma conta na plataforma. Esse processo só pode ser feito através do navegador na [página de inscrição](https://hub.docker.com/register/) do Dockerhub, ou seja, ainda não é possível criar uma conta pelo terminal.

![Dockerhub](images/Dockerhub.png)

Ao acessar o endereço você deve inserir um novo ID do Docker, (nome de usuário), um endereço de e-mail e uma senha. O navegador irá mostrar uma tela de `Welcome to Docker Hub`. Após o cadastro, entre na conta informada e procure o e-mail intitulado `Please confirm email for your Docker ID`, caso não encontre, não esqueça de checar a sua caixa de spam.

Abra o e-mail e clique em `Confirm Your Email`, o navegador irá abrir o Dockerhub e redirecionar você para o seu perfil. Nessa página clique em `Create Repository` e preencha um pequeno formulário com o nome do repositório e uma breve descrição, certifique-se de que o repositório esteja como público para que outras pessoas possam visualizar a sua imagem.

A conta gratuita possui direito a um repositório privado. Há [planos](https://hub.docker.com/account/billing-plans/) pagos para que mais repositórios privados fiquem disponíveis.

### Como enviar sua imagem para o Dockerhub

Agora que você já tem a sua conta e criou um repositório vamos enviar a sua imagem para o repositório. Se esse conceito ainda não está claro para você, tente fazer um paralelo com enviar um projeto para o Github utilizando o Git, pois é isso que vamos fazer agora. Ao utilizar o comando `docker image ls` você verá todas as imagens armazenadas localmente na sua máquina. Vamos imaginar que queremos subir a nossa imagem **docker-is-cool** para o repositório que acabamos de criar pelo navegador.

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
docker-is-cool      latest              8d9495d05463        38 minutes ago      193.4 MB
ambientum/node      6                   cee61c8e3d01        2 weeks ago         346 MB
nginx               stable-alpine       f94d6dd9b576        3 weeks ago         54 MB
```

Ao utilizar o comando `docker image ls` seu resultado será similar ao acima.

#### Taggeando a sua imagem

Antes de enviarmos nossa imagem para a nuvem precisamos taggea-la com o comando `docker tag`. Como vimos acima na coluna **REPOSITORY** a imagem **docker-is-cool** não mostra quem a criou em seu nome. Você precisa do comando [docker tag](https://docs.docker.com/engine/reference/commandline/tag/) para associar a imagem a sua conta Dockerhub incluindo um `namespace` antes do nome da imagem. O comando será semelhante ao abaixo.

![Dockertag](images/Dockerhub-tag.png)

Funciona da seguinte maneira: Usamos o comando `docker tag` e passamos como parâmetros o nome ou ID da imagem que queremos aplicar a tag. Que no nosso exemplo será **docker-is-cool**. Depois informamos o namespace que é o nome da conta do Dockerhub que criamos anteriormente e o nome da imagem, seguindo de dois pontos `:` e a versão ou tag de versão, o nosso exemplo ficaria da seguinte maneira.

`docker tag docker-is-cool SEU_DOCKER_ID/docker-is-cool:latest`

Você pode utilizar o comando `docker image ls` novamente e verá que a imagem que taggeou estará listada na tabela porém com o seu Docker ID no começo, como fizemos no comando acima, se você conseguiu esse resultado podemos enviá-la para a nuvem.

#### Como dar Push sua imagem

Antes de aprendermos como empurrar nossa imagem para o Dockerhub precisamos fazer login com a conta que nós criamos. Abra o terminal e digite o comando `docker login`, ele não aceita parâmetros mas solicita o seu usuário e senha para realizar o login como no exemplo abaixo.

```
docker login

    Username: *****
    Password: *****
    Login Succeeded
```

Após o login realizado com sucesso podemos enviar nossa imagem utilizando o comando `docker image push`, o comando gera diversos outputs, não se assuste, isso acontece porque cada camada é pushada separadamente. Ao utilizar o comando seu retorno será similar ao abaixo.

```
docker image push dockerID/docker-is-cool

The push refers to a repository [dockerID/docker-is-cool] (len: 1)
8d9495d05463: Image already exists
...
e9e06b06e14c: Image successfully pushed
Digest: sha256:ad89e88beb7dc73bf55d456e2c600e0a39dd6c9500d7cd8d1025626c4b985011
```

Após o término do comando você pode acessar o seu perfil no Dockerhub e visualizar a sua imagem na sua lista.

#### Como dar Pull na sua imagem

Como já foi mencionado todo o processo e objetivo é bastante similar ao uso do Git, o `docker image pull` permite que você e outras pessoas tenham fácil acesso a suas imagens em qualquer lugar, assim como seus projetos no Github. Porém, você precisa remover a cópia local. Caso contrário, [docker pull](https://docs.docker.com/engine/reference/commandline/pull/) não terá qualquer trabalho a fazer, porque ele vai ver que você já tem a versão mais recente da imagem localmente, pois acabamos de enviar ela para o Dockerhub.

Utilizamos novamente o comando `docker images` para pegarmos o ID da imagem que queremos excluir e utilizamos o comando `docker images rm -f ID_IMAGEM`, outra opção mais curta e mais comum é utilizarmos o comando `docker rmi -f ID`, no nosso caso ficaria da seguinte maneira.

`docker rmi -f 8d9495d05463`

Pronto agora podemos baixar a nossa imagem. Uma maneira inteligente de fazer isso é utilizando o comando `docker container run` que automaticamente baixa (puxa) imagens que ainda não existem localmente, cria e inicia um contêiner. Use o comando a seguir para puxar e executar a imagem **docker-is-cool**.

`docker run SEU_USUARIO_DOCKER/docker-is-cool`

Como você já aprendeu, cada camada é baixada separadamente, isso fica claro no output do comando que utilizamos no final a sua saída deve ser similar ao bloco abaixo.

```
Unable to find image 'SEU_USUARIO_DOCKER/docker-is-cool:latest' locally
latest: Pulling from SEU_USUARIO_DOCKER/docker-is-cool
faecf96fd5ab: Pull complete 
...
413db2f5215b: Pull complete 
Digest: sha256:66a9155c820efd2884512ba4b6e6c20a567da6c9a4ee5efdb740912a635fe17d
Status: Downloaded newer image for SEU_USUARIO_DOCKER/docker-is-cool:latest
```
