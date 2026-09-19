PRAGMA foreign_keys = ON;

CREATE TABLE reporting_context (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    as_of_date TEXT NOT NULL
);
CREATE TABLE months (
    month TEXT PRIMARY KEY CHECK (length(month) = 10 AND substr(month, 9, 2) = '01')
);
CREATE TABLE participants (
    participant_id INTEGER PRIMARY KEY,
    participant_code TEXT NOT NULL UNIQUE
);
CREATE TABLE programs (
    program_id INTEGER PRIMARY KEY,
    program_name TEXT NOT NULL UNIQUE,
    monthly_capacity INTEGER NOT NULL CHECK (monthly_capacity > 0)
);
CREATE TABLE enrollments (
    enrollment_id INTEGER PRIMARY KEY,
    participant_id INTEGER NOT NULL REFERENCES participants,
    program_id INTEGER NOT NULL REFERENCES programs,
    month TEXT NOT NULL REFERENCES months,
    UNIQUE (participant_id, program_id, month)
);
CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    enrollment_id INTEGER NOT NULL REFERENCES enrollments,
    occurred_at TEXT NOT NULL,
    kind TEXT NOT NULL CHECK (kind IN ('charge', 'refund')),
    status TEXT NOT NULL CHECK (status IN ('succeeded', 'failed')),
    amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
    refund_of INTEGER REFERENCES payments,
    CHECK ((kind = 'charge' AND refund_of IS NULL) OR (kind = 'refund' AND refund_of IS NOT NULL))
);
CREATE TABLE sessions (
    session_id INTEGER PRIMARY KEY,
    program_id INTEGER NOT NULL REFERENCES programs,
    session_date TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('held', 'canceled'))
);
CREATE TABLE attendance (
    session_id INTEGER NOT NULL REFERENCES sessions,
    enrollment_id INTEGER NOT NULL REFERENCES enrollments,
    present INTEGER NOT NULL CHECK (present IN (0, 1)),
    PRIMARY KEY (session_id, enrollment_id)
);
CREATE INDEX idx_enrollments_program_month ON enrollments(program_id, month);
CREATE INDEX idx_payments_date ON payments(occurred_at);
CREATE INDEX idx_sessions_program_date ON sessions(program_id, session_date);
