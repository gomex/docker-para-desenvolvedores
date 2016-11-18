# Instalando no MacOS

A instalação das ferramentas do Ecosistema Docker no MacOS será realizada através de um único grande pacote, que se chama **Docker Toolbox**.

Você pode instalar via brew cask com o comando abaixo:

```
brew cask install docker-toolbox
```

Você pode instalar manualmente acessando [a página de download](https://www.docker.com/products/docker-toolbox) do **Docker toolbox** e baixando o instalador correspondente ao MacOS.

Após duplo clique no instalador, verá essa tela:

![](images/mac1.png)

Apenas clique em **Continue**.

![](images/mac2.png)

Marque todas as opções e clique **Install**.

Será solicitado seu usuário e senha para liberar a instalação dos softwares. Preencha e continue o processo.

Na próxima tela será apenas apresentado as ferramentas que podem ser usadas para facilitar sua utilização do Docker no MacOS.

![](images/mac3.png)

Apenas clique em **Continue**.

Essa é ultima janela que verá nesse processo de instalação.

![](images/mac4.png)

Apenas clique em **Close** e finalize a instalação.

Para testar, procure e execute o software **Docker Quickstart Terminal**, pois ele fará todo processo necessário para começar a utilizar o Docker.

Nesse novo terminal execute o seguinte comando para teste:

```
docker run hello-world
```
