# Paridade entre desenvolvimento/produção

Seguindo a lista do modelo [12factor](http://12factor.net/pt_br), temos **“Paridade entre desenvolvimento/produção”** como décima boa prática.

![](images/paridade1.png)

Infelizmente na maioria dos ambientes de trabalho com software, existe um grande abismo entre o desenvolvimento e a produção. Esse grande buraco não é um mero acaso ou falta de sorte. Ele existe por conta de algumas diferenças entre as equipes de desenvolvimento e infraestrutura. De acordo com o 12factor elas manifestam-se nos seguintes âmbitos:

 * **Tempo**: Um desenvolvedor pode trabalhar em código que demora dias, semanas ou até meses para ir para produção.
 * **Pessoal**: Desenvolvedores escrevem código, engenheiros de operação fazem o deploy dele.
 * **Ferramentas**: Desenvolvedores podem estar usando um conjunto como Nginx, SQLite, e OS X, enquanto o app em produção usa Apache, MySQL, e Linux.

O 12factor pretende colaborar com base em suas boas práticas reduzir esse abismo entre as equipes e equalizar os ambientes em questão. Com relação aos âmbitos apresentados, seguem as respectivas propostas:

 * **Tempo**: um desenvolvedor pode escrever código e ter o deploy feito em horas ou até mesmo minutos depois.
 * **Pessoal**: desenvolvedores que escrevem código estão proximamente envolvidos em realizar o deploy e acompanhar seu comportamento em produção.
 * **Ferramentas**: mantenha desenvolvimento e produção o mais similares possível.

A solução de contêiner tem como um dos principais objetivos colaborar com essa portabilidade entre ambiente de desenvolvimento e produção, pois a ideia é que a imagem seja construída e apenas o seu status modifique para que ela seja posta em produção. O nosso código atual já está pronto para esse tipo de comportamento, sendo assim não há muito o que precise ser modificado para garantir essa boa prática, que será como um bônus pela adoção do Docker e o seguimento das outras boas práticas do 12factor.

[Capítulo anterior: Descartabilidade](descartabilidade.md) | [Próximo capítulo: Logs](logs.md)