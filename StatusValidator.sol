// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract StatusValidator {
    // Define una estructura de datos llamada Step para almacenar información sobre un paso en el flujo de proceso
    struct Step {
        Status status; // El estado actual del paso
        string metadata; // Metadatos adicionales sobre el paso
    }

    // Un enumerable llamado Status que define los diferentes estados posibles de un paso en el flujo de proceso
    enum Status {
        CONFIRMED_PO, // status 0
        BOOKING_REQUEST, // status 1
        SHIPMENT_IN_TRANSIT, // status 2
        SHIPMENT_AT_DESTINATION, // status 3
        CUSTOMS, // status 4
        DELIVERED, // status 5
        COMPLETED // status 6
    }

    // Un evento llamado RegisteredStep que se activa cuando una PO se registra en el flujo 
    event RegisteredStep(
        uint256 POID, // ID del producto
        Status status, // Estado del paso
        string metadata, // Metadatos adicionales
        address author // Dirección del autor
    );

    // El mapping guarda el ID de la PO y un array asociado con cada Step de la misma.
    mapping(uint256 => Step[]) public POvalidator;

    // Una función para registrar una PO que contendrá steps.
    function registerPO(uint256 POID) public returns (bool success) {
        // Comprueba que la PO no haya sido registrado previamente.
        require(POvalidator[POID].length == 0, "This product already exists");
        // Agrega un paso inicial al producto con el estado "CONFIRMED_PO".
        POvalidator[POID].push(Step(Status.CONFIRMED_PO, ""));
        return success;
    }

    // Una función para registrar un nuevo paso en el flujodel proceso.
    function registerStep(uint256 POID, string calldata metadata) public returns (bool success){
        // Comprueba que la PO haya sido registrado previamente.
        require(POvalidator[POID].length > 0, "This Purchase Order doesn't exist");
        // Obtiene la matriz de pasos actual para el producto.
        Step[] memory stepsArray = POvalidator[POID];
        // Calcula el estado siguiente para el paso actual.
        uint256 currentStatus = uint256(stepsArray[stepsArray.length - 1].status) + 1;
        // Dado el caso de que el status sea mayor a COMPLETED envía error
        if (currentStatus > uint256(Status.COMPLETED)) {
            revert("The Purchase Order has no more steps");
        }
        // Se asigna el estado actual + 1 y se añade al mapping de PO
        Step memory step = Step(Status(currentStatus), metadata);
        POvalidator[POID].push(step);
        // Se lanza evento donde se registra nuevo step a unu PO
        emit RegisteredStep(POID, Status(currentStatus), metadata, msg.sender);
        success = true;
    }
}