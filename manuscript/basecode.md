#  Base de código

Com o objetivo de facilitar o controle das mudanças de código, viabilizando a rastreabilidade das alterações, essa boa prática indica que cada aplicação deve ter apenas uma base de código e, partindo dessa, ser implantada em distintos ambientes. Vale salientar que essa prática também é parte das práticas de Continuous Integration ([CI](https://www.thoughtworks.com/continuous-integration)). Tradicionalmente, a maioria dos sistemas de integração contínua tem, como ponto de partida, uma base de código que é construída e, posteriormente, implantada em desenvolvimento, teste e produção.

Para essa explicação, usamos o sistema de controle de versão Git e o serviço de hospedagem Github. Criamos e disponibilizamos um [repositório](https://github.com/gomex/exemplo-12factor-docker.git) de exemplo.

Perceba que todo código está dentro do repositório, organizado por prática em cada pasta, para facilitar a reprodução. Lembre-se de entrar na pasta correspondente a cada boa prática apresentada.

O Docker tem possibilidade de utilizar variável de ambiente para parametrização da infraestrutura. Sendo assim, a mesma aplicação terá comportamento distinto com base no valor das variáveis de ambiente.

Aqui usamos o Docker Compose para realizar a composição de diferentes serviços pertinentes para a aplicação em tempo de execução. Desse modo, devemos definir a configuração desses distintos serviços e a forma como se comunicam.

![](images/basecode.png)

Posteriormente, mais precisamente na terceira boa prática, chamada **Configuração**, desse compêndio de sugestões, trataremos com mais detalhes sobre parametrização da aplicação. Por ora, apenas aplicamos opções via variável de ambiente para a arquitetura, ao invés de, utilizar internamente no código da aplicação.

Para configurar o ambiente de desenvolvimento para o exemplo apresentado, criamos o arquivo docker-compose.yml:

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

Podemos notar que o serviço "redis" é utilizado a partir da imagem oficial "redis", sem modificação. E o serviço web é gerado a partir da construção de uma imagem Docker.

Para a construção da imagem Docker do serviço web, criamos o seguinte Dockerfile, usando como base a imagem oficial do python 2.7:

```
FROM python:2.7
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
ADD . /code
WORKDIR /code
CMD python app.py
```

De posse de todos os arquivos na mesma pasta, iniciamos o ambiente com o seguinte comando:

```
export ENV_APP=devel ; docker-compose -p $ENV_APP up -d
```

Como podemos perceber no exemplo desse capítulo, a variável de ambiente `ENV_APP` define qual volume é usado para persistir os dados que são enviados pela aplicação web. Ou seja, com base na mudança dessa opção, teremos o serviço rodando com comportamento diferente, mas sempre a partir do mesmo código. Dessa forma, segue o conceito da primeira boa prática.
