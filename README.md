# Plate Recognition, DDU
Projektet består i at implementere et ANPR system i Processing.

Gruppen består af Christian Vedel Petersen, 3d1 og Emil Boesgaard Nørbjerg, 3d1.
Projektet er gruppens eksamensprojekt i faget Digital Design og Udvikling på H.C. Ørsted Gymnasiet, Lyngby.
Projektet afsluttes 2021-05-16.

## Resumé
Denne rapport beskriver udviklingen og implementeringen af et system til genkendelse af nummerplader på personbiler. 
Projektet er udarbejdet som en del af eksamen i faget Digital Design og Udvikling på H. C. Ørsted Gymnasiet i Lyngby. 
Der er gennem projektperioden blevet arbejdet med en iterativ metode til at udvikle systemet, 
hvor der bliver dannet opgaver ud fra user stories. Programmet benytter sig af teknikker som blob segmentation, 
connected-component analysis og neurale netværk til genkendelse af indholdet på nummerpladen. 
Med en præcision på 76.3% kan programmet succesfuldt genkende nummerplader. 
Oftest fejler programmet ved lokalisering af nummerpladen på bilen. 
De fejlede nummerplader er hovedsageligt mørkt farvede nummerplader, samt skæve eller slørrede billeder. 7
Der er altså med tilfredsstillende præcision lykkedes at skabe en system, der kan genkende nummerplader automatisk.

## Abstract
This paper describes the development and implementation of a system for recognizing number plates on passenger cars.
The project has been made as part of an exam in the subject Digital Design and Development at H. C. Ørsted Gymnasiet in Lyngby. 
During the project period, an iterative method has been used to develop the system, where tasks are formed based on user stories.
The program utilises techniques such as blob segmentation, connected-component analysis and neural networks
to recognize the contents of the license plate. With an accuracy of $76.3\%$, the program can successfully recognize license plates. 
Most often, the program fails when locating the license plate on the car. 
The incorrect number plates are mainly dark colored number plates, as well as skewed or blurred images. 
Therefore, there has been created a system that, with satisfactory precision, can succesfully recognize number plates automatically.

##Brugervejledning
Som bruger er der 4 knapper at trykke på. Den første er "Select a file". Her kan man vælge en .jpg eller .png fil, hvorpå der er en nummerplade.
Dette billede vil derefter blive analyseret af programmet. Når programmet har analyseret billedet, vil det blive vist på skærmen sammen med de fundne tegn.
Det er vigtigt at billedet er taget nogenlunde ligepå og ikke er for taget for langt væk.
Den anden knap er "Test program". Denne knap gør igennem alle filerne i mappen data/plates/. Hvis der ikke er nogle billeder i denne mappe,
gør knappen ingenting. Den tredje knap er "Export current picture". Når der trykkes på denne knap eksporterer programmet det nuværende billede
til mappen data/exports/, hvor filnavnet er den fundne nummerplade. Hvis programmet ikke har fundet en nummerplade, bliver filnavnet det nuværende
unix timestamp. Hvis det ikke er blevet analyseret et billede endnu, sker der ingenting. Den sidste knap åbner config-filen, hvor brugeren kan ændre
på formatet af nummerpladen, hvis der eksempelvis bruges udenlandske nummerplader. Man kan også ændre på hvilken farve teksten på bilen er,
så sorte og blå nummerplader, der har hvid skrift, også kan blive genkendt.