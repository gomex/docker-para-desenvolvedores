# Paridade entre desenvolvimento/produção

Seguindo a lista do modelo [12factor](https://12factor.net/pt_br/), temos **“Paridade entre desenvolvimento/produção”** como décima boa prática.

![](images/paridade1.png)

Infelizmente, na maioria dos ambientes de trabalho com software, existe grande abismo entre desenvolvimento e produção. Não é mero acaso ou falta de sorte, existe por conta das diferenças entre as equipes de desenvolvimento e as de infraestrutura. E, de acordo com o 12factor, manifestam-se nos seguintes âmbitos:

 * **Tempo**: o desenvolvedor pode trabalhar um código que demora dias, semanas ou até meses para ser transferido à produção.
 * **Pessoal**: desenvolvedores escrevem código, engenheiros de operação fazem o deploy do código.
 * **Ferramentas**: desenvolvedores podem usar conjuntos como Nginx, SQLite e OS X, enquanto o app em produção, usa Apache, MySQL e Linux.

O 12factor pretende colaborar para reduzir o abismo entre as equipes e equalizar os ambientes. Com relação aos âmbitos apresentados, seguem as respectivas propostas:

 * **Tempo**: desenvolvedor pode escrever código e ter o deploy concluído em horas ou até mesmo minutos depois.
 * **Pessoal**: desenvolvedores que escrevem código estão proximamente envolvidos em realizar o deploy e acompanhar o comportamento na produção.
 * **Ferramentas**: manter desenvolvimento e produção o mais similares possível.

A solução de contêiner tem como um dos principais objetivos colaborar com a portabilidade entre ambiente de desenvolvimento e produção. A ideia é que a imagem seja construída e apenas seu status modifique para ser posta em produção. O código atual já está pronto para esse comportamento, assim, não há muito a ser modificado para garantir a boa prática. É como um bônus pela adoção do Docker e o seguimento das outras boas práticas do 12factor.
