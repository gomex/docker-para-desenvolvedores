#  Base de código

Com o objetivo de facilitar o controle das mudanças de código, viabilizando a rastreabilidade das alterações, essa boa prática indica que cada aplicação deve ter apenas uma base de código e partindo desse ser implantada em distintos ambientes. Vale salientar que essa prática também parte da das práticas de Continuous Integration ([CI](https://www.thoughtworks.com/continuous-integration)). Tradicionalmente, a maioria dos sistemas de integração contínua tem como ponto de partida uma base de código que é construído e posteriormente implantado em desenvolvimento, teste e produção.

Para essa explicação, usaremos o sistema de controle de versão Git e o serviço de hospedagem Github. Criamos e disponibilizamos um [repositório](https://github.com/gomex/exemplo-12factor-docker.git) de exemplo.

Perceba que todo código está dentro desse repositório, organizado por prática em cada pasta, para facilitar a reprodução. Lembre de entrar na pasta correspondente a cada boa prática apresentada.

Docker tem uma infraestrutura que permite a utilização de variável de ambiente para parametrização da infraestrutura, sendo assim a mesma aplicação terá um comportamento distinto com base no valor das variáveis de ambiente.

Aqui usaremos o Docker Compose para realizar a composição de diferentes serviços importantes para a aplicação em tempo de execução. Desse modo devemos definir a configuração desses distintos serviços e a forma como se comunicam.

![](images/basecode.png)

Posteriormente, mais precisamente na terceira boa prática **Configuração** desse compêndio de sugestões, trataremos mais detalhadamente sobre parametrização da aplicação, por hora apenas aplicaremos opções via variável de ambiente para a arquitetura ao invés de utilizar internamente no código da aplicação.

Para configurar o ambiente de desenvolvimento para o exemplo apresentado criamos esse arquivo docker-compose.yml:

```
version: '2'
services:
  web:
    build: .
    ports:
     - "5000:5000"
    volumes:
     - .:/code
    labels:
     - 'app.environment=${ENV_APP}'
  redis:
    image: redis
    volumes:
     - dados_${ENV_APP}:/data
    labels:
     - 'app.environment=${ENV_APP}'
```

Podemos notar que o serviço redis será utilizado a partir da imagem oficial
redis, sem modificação e o serviço web será gerado a partir da construção de
uma imagem Docker.

Para contrução da imagem Docker do serviço web, criamos o seguinte Dockerfile
usando como base a imagem oficial do python 2.7:

```
FROM python:2.7
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
ADD . /code
WORKDIR /code
CMD python app.py
```

Com posse de todos os arquivos na mesma pasta, iniciaremos o ambiente com o seguinte comando:

```
export ENV_APP=devel ; docker-compose -p $ENV_APP up -d
```

Como podemos perceber no exemplo desse capítulo, a variável de ambiente `ENV_APP` definirá qual volume será usado para persistir os dados que serão enviados pela aplicação web. Ou seja, com base na mudança dessa opção teremos o serviço rodando com um comportamento diferente, mas sempre a partir do mesmo código, dessa forma seguindo o conceito dessa primeira boa prática.

[Capítulo anterior: Transformando sua aplicação em container](dockerizarando_app_todo.md) | [Próximo capítulo: Dependência](dependencia.md)