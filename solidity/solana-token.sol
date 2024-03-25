// Import necessary libraries for SPL token and metadata handling.
import "../libraries/spl_token.sol";
import "../libraries/mpl_metadata.sol";

// Define the program contract with the specified program ID on the Solana blockchain.
@program_id("F1ipperKF9EfD821ZbbYjS319LXYiBmjhzkkf5a26rC")
contract spl_token_minter {
    @payer(payer) // payer for the "data account"
    constructor() {}

    // Function to create a new token mint and associated metadata.
    @mutableSigner(payer) // payer account
    @mutableSigner(mint) // mint account to be created
    @mutableAccount(metadata) // metadata account to be created
    @signer(mintAuthority) // mint authority for the mint account
    @account(rentAddress)
    @account(metadataProgramId)
    function createTokenMint(
        address freezeAuthority, // freeze authority for the mint account
        uint8 decimals, // decimals for the mint account
        string name, // name for the metadata account
        string symbol, // symbol for the metadata account
        string uri // uri for the metadata account
    ) external {
        // Invoke System Program to create a new account for the mint account and,
        // Invoke Token Program to initialize the mint account
        // Set mint authority, freeze authority, and decimals for the mint account
        SplToken.create_mint(
            tx.accounts.payer.key,            // payer account
            tx.accounts.mint.key,            // mint account
            tx.accounts.mintAuthority.key,   // mint authority
            freezeAuthority, // freeze authority
            decimals         // decimals
        );

        // Invoke Metadata Program to create a new account for the metadata account
        MplMetadata.create_metadata_account(
            tx.accounts.metadata.key, // metadata account
            tx.accounts.mint.key,  // mint account
            tx.accounts.mintAuthority.key, // mint authority
            tx.accounts.payer.key, // payer
            tx.accounts.payer.key, // update authority (of the metadata account)
            name, // name
            symbol, // symbol
            uri, // uri (off-chain metadata json)
            tx.accounts.rentAddress.key,
            tx.accounts.metadataProgramId.key
        );
    }

    // Function to mint tokens to a specified token account.
    @mutableAccount(mint)
    @mutableAccount(tokenAccount)
    @mutableSigner(mintAuthority)
    function mintTo(uint64 amount) external {
        // Mint tokens to the token account
        SplToken.mint_to(
            tx.accounts.mint.key, // mint account
            tx.accounts.tokenAccount.key, // token account
            tx.accounts.mintAuthority.key, // mint authority
            amount // amount
        );
    }
}