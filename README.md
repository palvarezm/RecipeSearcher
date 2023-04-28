# RecipeSearcher

Yape coding challenge

Se usó la versión de XCode 13.2

### Decisiones técnicas
- Se optó por el uso de MVVM ya que al ser un coding challenge corto no había necesidad de usar Clean o VIPER que tienen mucho boilerplate code.
- Creación de una capa de Network para realizar los request y poder extender su uso de manera fácil
- Combine para los llamados a los endpoints y para el manejo de acciones por parte de los usuarios([Input/Output](https://github.com/palvarezm/RecipeSearcher/blob/feature/readme/RecipeSearcher/RecipeSearcher/Sources/Modules/Home/ViewModel/HomeViewModel.swift#L11))

### Librerías externas
[SDWebImage](https://github.com/SDWebImage/SDWebImage "SDWebImage"): Para la carga de las imagenes de las recetas en la cache.

### Servicios back-end
Se hizo uso de mockable para no desarrollar los servicios:
- [Get recipes](https://demo7321057.mockable.io/recipes)
- [Get recipe detail](https://demo7321057.mockable.io/recipe?id=1)

### Screenshots
## Home
![Home](https://user-images.githubusercontent.com/24754685/235015027-d12ed4e1-8aec-40fb-bd0b-be05de407bd6.png)

## Home search by name
![Home](https://user-images.githubusercontent.com/24754685/235015025-c2914b50-b368-40b5-8357-d5d2602bd342.png)

## Home search by ingredient
![Home](https://user-images.githubusercontent.com/24754685/235015022-9be4fee8-b9f4-4f22-a772-10f41fb122ee.png)


## Recipe Detail
![Home](https://user-images.githubusercontent.com/24754685/235015031-ae25e9ca-d0e9-4eed-8798-f09c2c7c1d83.png)


## Recipe origin on map location
![Home](https://user-images.githubusercontent.com/24754685/235015038-3af448d3-19d4-492b-a295-09b7f8b151de.png)
