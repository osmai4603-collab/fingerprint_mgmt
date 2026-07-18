class TokenBlacklist:
    def __init__(self):
        self._blacklist: set[str] = set()

    def add(self, token: str) -> None:
        self._blacklist.add(token)

    def contains(self, token: str) -> bool:
        return token in self._blacklist


token_blacklist = TokenBlacklist()
