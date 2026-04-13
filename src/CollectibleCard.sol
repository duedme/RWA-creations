// SPDX-License-Identifier: Apache-2.0
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

import {
    AccessManagedUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {ERC1155Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import {
    ERC1155PausableUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
import {
    ERC1155SupplyUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract CollectibleCard is
    Initializable,
    ERC1155Upgradeable,
    AccessManagedUpgradeable,
    ERC1155PausableUpgradeable,
    ERC1155SupplyUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    struct Card {
        string cardName;
        string description;
        uint16 amount;  // Total of fractions
        uint256 pricePerFraction;
        bool metadataFrozen;
    }

    uint256 private _cardId;

    event CardCreated(uint256 indexed cardId, string cardName, uint256 originalPrice, uint16 amount);

    mapping(uint256 => Card) public cards;
    mapping(uint256 => string) private _cardsURI;

    function createCard(
        address to,
        string calldata cardName,
        string calldata description,
        uint16 amount,
        string calldata tokenURI,
        uint256 price
    ) external restricted {
        uint256 _newId = _cardId;


        cards[_newId] = Card({cardName: cardName, description: description, amount: amount, pricePerFraction: price, metadataFrozen: false});
        _cardsURI[_newId] = tokenURI;

        _cardId++;

        mint(to, _newId, amount, "");

        emit CardCreated(_newId, cardName, price, amount);
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialAuthority) public initializer {
        __ERC1155_init("");
        __AccessManaged_init(initialAuthority);
        __ERC1155Pausable_init();
        __ERC1155Supply_init();
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        require(tokenId < _cardId, "Card does not exist");

        string memory tokenURI = _cardsURI[tokenId];

        if (bytes (tokenURI).length > 0) {
            return tokenURI;
        }

        return super.uri(tokenId);
    }

    function setTokenURI(uint256 tokenId, string calldata newURI)
        external restricted
    {
        require(tokenId < _cardId, "Card does not exist");
        require(!cards[tokenId].metadataFrozen, "Metadata is frozen");
        _cardsURI[tokenId] = newURI;
        emit URI(newURI, tokenId);
    }

    function freezeMetadata(uint256 tokenId) external {
        require(tokenId < _cardId, "Card does not exist");

        cards[tokenId].metadataFrozen = true;
    }

    function pause() public restricted {
        _pause();
    }

    function unpause() public restricted {
        _unpause();
    }

    function mint(address account, uint256 id, uint16 amount, bytes memory data)
        public
        restricted
    {
        _mint(account, id, amount, data);
    }

    /* function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        restricted
    {
        _mintBatch(to, ids, amounts, data);
    } */

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155Upgradeable, ERC1155PausableUpgradeable, ERC1155SupplyUpgradeable)
    {
        super._update(from, to, ids, values);
    }
}

/*
Posibles pasos:

- Crear una lista de admins y lista de dueños

- Crear carta con la información proporcionada
    - Dividir carta en múltiples tokens
    - Cada token con las características de identificación y precio
- Crear lógica de mercado para:
    - Comprar
    - Vender
    - Transferir
- Crear lógica para información (esto sólo debe emitir eventos):
    - Obtener información de la carta
    - Obtener información de los tokens
    - Obtener información de la mercado
    - Obtener información de los transacciones
    - Obtener información de los holders
    - Obtener información de los precios
    - Obtener información de los volúmenes

- Lógica de precios:
    - Actualizar precios de los tokens

- Lógica para clientes:
    - Distribuir dividendos (debería ser en automático y proporcional a la cantidad de tokens que tiene el holder)
    - Esto debe ser PULL over PUSH
    - Pausar el contrato en caso de emergencia
    - Despausar el contrato en caso de emergencia

- Lógica para el owner:
    - Retirar fondos del contrato

- Lógica de negocio:
    - Estandar de regalías (EIP-2981) para

- Bloquear actualización de metadata




 */

