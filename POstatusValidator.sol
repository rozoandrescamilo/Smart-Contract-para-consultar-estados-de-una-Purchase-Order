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
        TO_BE_CONFIRMED, 
        APPROVED_P1, 
        TO_BE_CONFIRMED_P2, 
        APPROVED_P2, 
        TO_BE_CONFIRMED_P3, 
        APPROVED_P3,
        BOOKING_REQUEST 
    } 

    // Un evento llamado RegisteredStep que se activa cuando una PO se registra en el flujo 
    event RegisteredStep(
        uint256 POID, // ID del producto
        uint256 poType, // Tipo de orden: Entrega total, 2 parciales o 3 parciales
        Status status, // Estado del paso
        string metadata, // Metadatos adicionales
        address author // Dirección del autor
    );

    // El mapping guarda el ID de la PO y un array asociado con cada Step de la misma.
    mapping(uint256 => Step[]) public ParameterValidator;

    // Una función para registrar una PO que contendrá steps.
    function RegisterPO(address userWallet, uint256 POID) public returns (bool success) {
        // Comprueba si la dirección de la wallet del usuario es igual a la del usuario que intenta interactuar
        require(userWallet == msg.sender, "To be able to interact with your Purchase Order you must use your registered wallet address");
        // Comprueba que la PO no haya sido registrado previamente.
        require(ParameterValidator[POID].length == 0, "This product already exists");
        // Agrega un paso inicial al producto con el estado "TO_BE_CONFIRMED".
        ParameterValidator[POID].push(Step(Status.TO_BE_CONFIRMED, ""));        
        return success;

    }

    // Una función para registrar un nuevo paso en el flujo del proceso.
    function RegisterStep(address userWallet, uint256 POID, string calldata metadata, uint256 poType) public returns (bool success) {
        // Comprueba si la dirección de la wallet del usuario es igual a la del usuario que intenta interactuar
        require(userWallet == msg.sender, "To be able to interact with your Purchase Order you must use your registered wallet address");
        // Comprueba que la PO haya sido registrado previamente.
        require(ParameterValidator[POID].length > 0, "This Purchase Order doesn't exist");
        // Comprueba que los tipos orden sean los correctos.
        require(poType == 1 || poType == 2 || poType == 3, "Invalid PO type");
        // Obtiene la matriz de pasos actual para el producto.
        Step[] memory stepsArray = ParameterValidator[POID];
        // Calcula el estado siguiente para el paso actual.
        uint256 currentStatus = uint256(stepsArray[stepsArray.length - 1].status) + 1;
        // Dado el caso de que el status sea mayor a COMPLETED envía error
        if (currentStatus > uint256(Status.BOOKING_REQUEST)) {
            revert("The Purchase Order has no more steps");
        }
        // Dado el tipo de estado 1 se da el máximo estado posible 2
        if (poType == 1 && currentStatus > 2) {
            revert("The maximum status for poType 1 is 2 BOOKING REQUEST");
        }
        // Dado el tipo de estado 2 se da el máximo estado posible 4
        if (poType == 2 && currentStatus > 4) {
            revert("The maximum status for poType 2 is 4 BOOKING REQUEST");
        }
        // Dado el tipo de estado 3 se da el máximo estado posible 6
        if (poType == 3 && currentStatus > 6) {
            revert("The maximum status for poType 3 is 6 BOOKING REQUEST");
        }
        // Se asigna el estado actual + 1 y se añade al mapping de PO
        Step memory step = Step(Status(currentStatus), metadata);
        ParameterValidator[POID].push(step);
        // Se lanza evento donde se registra nuevo step a unu PO
        emit RegisteredStep(POID, poType, Status(currentStatus), metadata, msg.sender);
        success = true;
    }

}
