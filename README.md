[![1](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/1.jpg?raw=true "1")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/1.jpg?raw=true "1")

- [Smart Contract para consultar estados de una Purchase Order](#smart-contract-para-consultar-estados-de-una-purchase-order)
  - [Función del Smart Contract](#función-del-smart-contract)
  - [Prueba en Entorno de Desarrollo Integrado RemixIDE](#prueba-en-entorno-de-desarrollo-integrado-remixide)

# Smart Contract para consultar estados de una Purchase Order

## Función del Smart Contract

En este repositorio se documentará un contrato inteligente usando la red de Ethereum, con el fin de crear un método para consultar los diferentes estados posibles de una Purchase Order desde CONFIRMED PO hasta COMPLETED.

Este es un contrato de Solidity para un validador de estatus de las Purchase Orders que pasen por el flujo de gestión de datos de DAWIPO. Este contrato utiliza una estructura llamada Step que tiene dos campos, uno para el estatus y otro para los metadatos. También tiene una enumeración llamada Status que define los posibles estados de un proceso de orden de compra.

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract StatusValidator {
    struct Step {
        Status status; 
        string metadata; 
    }

    enum Status {
        CONFIRMED_PO,
        BOOKING_REQUEST,
        SHIPMENT_IN_TRANSIT,
        SHIPMENT_AT_DESTINATION,
        CUSTOMS,
        DELIVERED,
        COMPLETED
    }
```

Además, hay un evento llamado RegisteredStep que registra los cambios de estado de una orden de compra. Hay un mapeo público llamado POvalidator que mantiene una lista de pasos para cada orden de compra.

```solidity
    event RegisteredStep(
        uint256 POID, // ID del producto
        Status status, // Estado del paso
        string metadata, // Metadatos adicionales
        address author // Dirección del autor
    );

    mapping(uint256 => Step[]) public POvalidator;
```

Hay dos funciones públicas en este contrato. La primera, registerPO, se usa para registrar una nueva orden de compra y se asegura de que la orden de compra no exista previamente. La segunda función, registerStep, se usa para registrar un nuevo paso en la orden de compra. Esta función requiere que la orden de compra exista y verifica si el nuevo estado es válido en función del estado actual. Si todo está bien, agrega el nuevo paso a la lista de pasos y emite el evento RegisteredStep.

```solidity
    function registerPO(uint256 POID) public returns (bool success) {
        require(POvalidator[POID].length == 0, "This product already exists");
        POvalidator[POID].push(Step(Status.CONFIRMED_PO, ""));
        return success;
    }

    function registerStep(uint256 POID, string calldata metadata) public returns (bool success){
        require(POvalidator[POID].length > 0, "This Purchase Order doesn't exist");
        Step[] memory stepsArray = POvalidator[POID];
        uint256 currentStatus = uint256(stepsArray[stepsArray.length - 1].status) + 1;
        if (currentStatus > uint256(Status.COMPLETED)) {
            revert("The Purchase Order has no more steps");
        }
        Step memory step = Step(Status(currentStatus), metadata);
        POvalidator[POID].push(step);
        emit RegisteredStep(POID, Status(currentStatus), metadata, msg.sender);
        success = true;
    }
}
```

## Prueba en Entorno de Desarrollo Integrado RemixIDE

Página oficial de RemixIDE: 
[https://remix.ethereum.org/](https://remix.ethereum.org/ "https://remix.ethereum.org/")

RemixIDE es un IDE (Integrated Development Environment) que se usa desde el navegador, cuenta con componentes para poder desplegar desde ahí los contratos, incluyendo un compilador. En la interfaz, del lado izquierdo, se puede encontrar el menú de ventanas principal para acceder al IDE, al compilador y demás. Desde aquí se hacen las configuraciones iniciales, se agrega el contrato StatusValidator.sol al directorio de Contracts:

[![1](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/1.png?raw=true "1")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/1.png?raw=true "1")

En la pestaña de SOLIDITY COMPILER se configura la versión del compilador de acuerdo con el pragma establecido en el contrato, el lenguaje que se empleará, la versión de la EVM y otros parámetros. Después de compilarse se podrá desplegar:

[![2](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/2.png?raw=true "2")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/2.png?raw=true "2")

En la sección de DEPLOY, se puede elegir la red que se utilizará, la cuenta con ether de pruebas y los parámetros específicos del contrato, como el límite de gas, que es básicamente una unidad de recurso dentro de la EVM, que se consume al desplegar un contrato y varía de acuerdo a las características de cada uno.

RemixIDE también cuenta con su propia terminal, por lo que podremos visualizar los datos de cada una de las salidas de transacciones y llamados en el contrato en el mismo entorno.

[![3](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/3.png?raw=true "3")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/3.png?raw=true "3")

Desplegado el contrato de validador de estatus correctamente, en la interfaz a la izquierda se puede visualizar la pestaña de Deployed Contracts, donde se utiliza esta para interactuar con el smart contract. 

A manera de ejemplo, en la sección de registerPO se puede registrar una nueva Purchase Order de un Cliente con un ID: "12345".

[![4](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/4.png?raw=true "4")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/4.png?raw=true "4")

Para verificar su estado actual es necesario dirigirse a la sección de POvalidator, con el ID de la Purchase Order y el número "0" que equivale al estado "CONFIRMED_PO", se puede hacer un llamado al smart contract y muestra como salida el status actual de la PO y un string que puede contener metadata del proceso hasta el momento:

[![5](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/5.png?raw=true "5")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/5.png?raw=true "5")

De acuerdo con el flujo de gestión de datos la PO debe seguir al siguiente estado "BOOKING_REQUEST", por lo tanto en la sección de registerStep con los datos del ID de la Purchase Order y como ejemplo de metadata "BOOKING_REQUEST OK" se registra un nuevo step en el contrato y se hace la transacción: 

[![6](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/6.png?raw=true "6")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/6.png?raw=true "6")

Para verificar se utiliza la sección de POvalidator, con el ID de la PO y el número "1" que equivale al estado "BOOKING_REQUEST", se puede hacer un llamado al smart contract y muestra como salida el status actual de la PO y un string que conteniene metadata del proceso hasta el momento:

[![7](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/7.png?raw=true "7")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/7.png?raw=true "7")

El código permite registrar y validar los siguientes estados hasta que la PO se encuentre COMPLETED.

SHIPMENT_IN_TRANSIT: status 2

[![8](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/8.png?raw=true "8")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/8.png?raw=true "8")

SHIPMENT_AT_DESTINATION: status 3

[![9](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/9.png?raw=true "9")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/9.png?raw=true "9")

CUSTOMS: status 4

[![10](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/10.png?raw=true "10")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/10.png?raw=true "10")

DELIVERED: status 5

[![11](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/11.png?raw=true "11")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/11.png?raw=true "11")

COMPLETED: status 6

[![12](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/12.png?raw=true "12")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/12.png?raw=true "12")

Al intentar registrar otro paso para la PO con ID "12345" que ya paso a estado COMPLETED, se genera el error: "The Purchase Order has no more steps", evitando que se incurra en pasos extra:

[![13](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/13.png?raw=true "13")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/13.png?raw=true "13")

Otra función que permite el smart contract es validar estados anteriores junto con la metadata que quedo atada a este step:

[![14](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/14.png?raw=true "14")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/14.png?raw=true "14")

También facilita que al momento de crear otros Purchase Orders con otros ID y otros status diferentes, se pueda validar datos de un PO anterior o diferente al que se está trabajando:

[![15](https://github.com/rozoandrescamilo/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/15.png?raw=true "15")](https://github.com/Smart-Contract-para-consultar-estados-de-una-Purchase-Order/blob/main/img/15.png?raw=true "15")



