pragma solidity ^0.5.16;

contract scrutin {
    
    struct detailScrutin {
        string typeElection;
        string lieuScrutin;
        uint dateDebut;
        uint dateFin;
    }
    
    struct Votant {
        uint weight;
        bool alreadyVote;
        uint vote;
    }

    struct Participant {
        bytes32 nom;
        uint nbVote;
    }

    address public adresseVotant;
    mapping(address => Votant) public detailVotant;
    
    detailScrutin private infoScrutin;
    Participant[] private participants;

    constructor (bytes32[] memory nomParticipants, string memory typeScrutin, string memory lieuElection, uint tempsElection) public {
        adresseVotant = msg.sender;
        detailVotant[adresseVotant].weight = 1;

        for (uint i = 0; i < nomParticipants.length; i++) {
            participants.push(Participant({nom: nomParticipants[i], nbVote: 0}));
        }
        
        infoScrutin.typeElection = typeScrutin;
        infoScrutin.lieuScrutin = lieuElection;
        infoScrutin.dateDebut = now;
        infoScrutin.dateFin = now + tempsElection;
    }
    
    // Conversion du format bytes32 en string pour définir le nom
    function bytes32ToStr(bytes32 bytesInput) private pure returns (string memory convertString) {
        bytes memory nomBytes = new bytes(32);
        for (uint256 j; j < 32; j++) {
            nomBytes[j] = bytesInput[j];
        }
        convertString = string (nomBytes);
    }

    function getTempsRestantScrutin() public view returns (uint tempsRestantMinutes)
    {
        tempsRestantMinutes = (infoScrutin.dateFin - now) / 60;
    }
    
    function getInfosParticipants(uint idCandidat) public view returns (string memory nom, uint nombreVote)
    {
        nom = bytes32ToStr(participants[idCandidat].nom);
        nombreVote = participants[idCandidat].nbVote;
    }
    
    function getInfosScrutin() public view returns (string memory typeScrutin, string memory lieuScrutin, uint debutScrutin, uint finScrutin) 
    {
        typeScrutin = infoScrutin.typeElection;
        lieuScrutin = infoScrutin.lieuScrutin;
        debutScrutin = infoScrutin.dateDebut;
        finScrutin = infoScrutin.dateFin;
    }
    
    function vote (uint idCandidat) public {
        Votant storage sender = detailVotant[msg.sender];
        if (now < infoScrutin.dateFin) {
            if (sender.alreadyVote) {
                revert("Vous avez déjà voté !");
            }
            sender.alreadyVote = true;
            sender.vote = idCandidat;
            participants[idCandidat].nbVote += sender.weight;
        }
        else {
            revert("Le scrutin est terminé, vous ne pouvez plus voter !");
        }
            
    }

    function afficherVainqueur() view public returns (string memory nomVainqueur, uint nombreVote)
    {
        uint countVoteWinner = 0;
        uint WinnerID;

        for (uint i = 0; i < participants.length; i++) {
            if (participants[i].nbVote > countVoteWinner) {
                WinnerID = i;
                countVoteWinner = participants[i].nbVote;
            }
        }
        nomVainqueur = bytes32ToStr(participants[WinnerID].nom);
        nombreVote = countVoteWinner;
    }
}