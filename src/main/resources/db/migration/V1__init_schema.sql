-- Mizan initial schema (PostgreSQL)

CREATE TABLE users (
                       id                   BIGSERIAL PRIMARY KEY,
                       username             VARCHAR(50)  NOT NULL,
                       email                VARCHAR(255) NOT NULL,
                       password_hash        VARCHAR(255) NOT NULL,
                       role                 VARCHAR(10)  NOT NULL DEFAULT 'USER',
                       auto_review_enabled  BOOLEAN      NOT NULL DEFAULT FALSE,
                       created_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       CONSTRAINT uq_users_username UNIQUE (username),
                       CONSTRAINT uq_users_email UNIQUE (email),
                       CONSTRAINT chk_users_role CHECK (role IN ('USER', 'ADMIN'))
);

CREATE TABLE stocks (
                        id                BIGSERIAL PRIMARY KEY,
                        ticker            VARCHAR(20)  NOT NULL,
                        name              VARCHAR(255) NOT NULL,
                        sector            VARCHAR(100),
                        sharia_compliant  BOOLEAN      NOT NULL DEFAULT FALSE,
                        created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        CONSTRAINT uq_stocks_ticker UNIQUE (ticker)
);

CREATE TABLE holdings (
                          id              BIGSERIAL PRIMARY KEY,
                          user_id         BIGINT         NOT NULL,
                          stock_id        BIGINT         NOT NULL,
                          quantity        INTEGER        NOT NULL,
                          purchase_price  NUMERIC(19, 4) NOT NULL,
                          purchase_date   DATE           NOT NULL,
                          status          VARCHAR(10)    NOT NULL DEFAULT 'OPEN',
                          close_price     NUMERIC(19, 4),
                          close_date      DATE,
                          created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          CONSTRAINT fk_holdings_user  FOREIGN KEY (user_id)  REFERENCES users (id),
                          CONSTRAINT fk_holdings_stock FOREIGN KEY (stock_id) REFERENCES stocks (id),
                          CONSTRAINT chk_holdings_status CHECK (status IN ('OPEN', 'CLOSED')),
                          CONSTRAINT chk_holdings_quantity CHECK (quantity > 0),
                          CONSTRAINT chk_holdings_purchase_price CHECK (purchase_price >= 0),
                          CONSTRAINT chk_holdings_close_price CHECK (close_price IS NULL OR close_price >= 0),
    -- a CLOSED holding must have close data, an OPEN one must not
                          CONSTRAINT chk_holdings_close_consistency CHECK (
                              (status = 'OPEN'   AND close_price IS NULL     AND close_date IS NULL) OR
                              (status = 'CLOSED' AND close_price IS NOT NULL AND close_date IS NOT NULL)
                              )
);

CREATE INDEX idx_holdings_user_id ON holdings (user_id);
CREATE INDEX idx_holdings_stock_id ON holdings (stock_id);
CREATE INDEX idx_holdings_user_status ON holdings (user_id, status);

CREATE TABLE price_snapshots (
                                 id             BIGSERIAL PRIMARY KEY,
                                 stock_id       BIGINT         NOT NULL,
                                 price          NUMERIC(19, 4) NOT NULL,
                                 snapshot_date  DATE           NOT NULL,
                                 created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 CONSTRAINT fk_price_snapshots_stock FOREIGN KEY (stock_id) REFERENCES stocks (id),
                                 CONSTRAINT uq_price_snapshots_stock_date UNIQUE (stock_id, snapshot_date),
                                 CONSTRAINT chk_price_snapshots_price CHECK (price >= 0)
);

CREATE TABLE rebalance_logs (
                                id              BIGSERIAL PRIMARY KEY,
                                user_id         BIGINT      NOT NULL,
                                holding_id      BIGINT,
                                action          VARCHAR(20) NOT NULL,
                                rebalance_date  DATE        NOT NULL,
                                notes           TEXT,
                                created_at      TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                CONSTRAINT fk_rebalance_logs_user    FOREIGN KEY (user_id)    REFERENCES users (id),
                                CONSTRAINT fk_rebalance_logs_holding FOREIGN KEY (holding_id) REFERENCES holdings (id),
                                CONSTRAINT chk_rebalance_logs_action CHECK (action IN ('OPENED', 'CLOSED', 'REVIEWED_NO_CHANGE'))
    );

CREATE INDEX idx_rebalance_logs_user_id ON rebalance_logs (user_id);
CREATE INDEX idx_rebalance_logs_holding_id ON rebalance_logs (holding_id);
CREATE INDEX idx_rebalance_logs_user_date ON rebalance_logs (user_id, rebalance_date);