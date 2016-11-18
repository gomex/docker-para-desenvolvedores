# Instalando no Windows

A instalação das ferramentas do Ecosistema Docker no Windows será realizada através de um único grande pacote, que se chama **Docker Toolbox**.

O **Docker Toolbox** funcionará apenas em [versões 64bit](https://support.microsoft.com/en-us/kb/827218) do Windows e apenas as versões superiores ao Windows 7.

É importante atentar também que é necessário que o suporte a virtualização esteja habilitado. Na versão 8 do Windows é possível verificar através do **Task Manager**, na aba **Performance**, clicando em **CPU** é possível visualizar a janela abaixo:

![](images/windows1.png)

Para verificar o suporte a virtualização do Windows 7, utilize esse [link](http://www.microsoft.com/en-us/download/details.aspx?id=592) para maiores informações.

### Instalando o Docker Toolbox

Acesse [a página de download](https://www.docker.com/products/docker-toolbox) do **Docker toolbox** e baixe o instalador correspondente ao Windows.

Após duplo clique no instalador, verá essa tela:

![](images/windows2.png)

Apenas clique em **Next**.

![](images/windows3.png)

Por fim clique em **Finish**.

Para testar, procure e execute o software **Docker Quickstart Terminal**, pois ele fará todo processo necessário para começar a utilizar o Docker.

Nesse novo terminal execute o seguinte comando para teste:

```
docker run hello-world
```
