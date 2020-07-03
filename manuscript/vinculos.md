# Vínculo de portas

De acordo com a lista do modelo [12factor](https://12factor.net/pt_br/), a sétima boa prática é **“Vínculo de portas”**.

É comum encontrar aplicações executadas dentro de contêineres de servidores web, tal como Tomcat, ou Jboss, por exemplo. Normalmente, essas aplicações são implantadas dentro dos serviços para que possam ser acessadas pelos usuários externamente.

![](images/vinculos1.png)

A boa prática sugere que o aplicativo em questão seja auto-contido e dependa de um servidor de aplicação, tal como Jboss, Tomcat e afins. O software deve exportar um serviço HTTP e lidar com as requisições que chegam por ele. Significa que, qualquer aplicação adicional é desnecessária para o código estar disponível à comunicação externa.

Tradicionalmente, a implantação de artefato em servidor de aplicação, tal como Tomcat e Jboss, exige a geração de um artefato e, esse, é enviado para o serviço web em questão. Mas no modelo de contêiner Docker, a idéia é que o artefato do processo de implantação seja o próprio contêiner.

O processo antigo de implantação do artefato em servidor de aplicação, normalmente, não tinha retorno rápido, o que aumentava demasiadamente o processo de implantação de um serviço, pois, cada alteração demandava enviar o artefato para o serviço de aplicação web; e, esse tinha a responsabilidade de importar, ler e executar o novo artefato.

Usando Docker, facilmente, a aplicação torna-se auto-contida. Já construímos um Dockerfile que descreve o que a aplicação precisa:

```
FROM python:2.7
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt
ADD . /code
WORKDIR /code
CMD python app.py
EXPOSE 5000
```

As dependências estão descritas no arquivo requirements.txt e os dados que devem ser persistidos são geridos por um serviço externo (serviços de apoio) à aplicação.

Outro detalhe da boa prática: a aplicação deve exportar o serviço através da vinculação a uma única porta. Como vemos no código exemplo, a porta padrão do python (5000) é iniciada, mas você pode escolher outra, se julgar necessário. Segue o recorte do código que trata do assunto:

```
if __name__ == "__main__":
  app.run(host="0.0.0.0", debug=True)
```

A porta 5000 pode ser utilizada para servir dados localmente em ambiente de desenvolvimento ou, através de proxy reverso, quando for migrada para produção, com nome de domínio adequado a aplicação em questão.

Utilizar o modelo de vinculação de portas torna o processo de atualização de aplicação mais fluído, uma vez que, na utilização de um proxy reverso inteligente, é possível adicionar novos nós gradativamente, com a nova versão, e remover os antigos à medida que as versões atualizadas são executadas em paralelo.

Convém salientar: mesmo que o Docker permita a utilização de mais de uma porta por contêineres, a boa prática enfatiza que você só deve utilizar uma porta vinculada por aplicação.
