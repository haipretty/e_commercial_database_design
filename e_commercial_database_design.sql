
-- 综合项目：电商数据库设计+查询
-- 建表与测试数据SQL

-- 1. 用户表
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(11) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    register_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1-正常，0-禁用'
);

-- 2. 商品分类表
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    parent_id INT DEFAULT 0 COMMENT '父分类ID，0表示一级分类',
    sort INT NOT NULL DEFAULT 0 COMMENT '排序权重',
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

-- 3. 商品表
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    description TEXT,
    is_online TINYINT NOT NULL DEFAULT 1 COMMENT '1-上架，0-下架',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 4. 用户收货地址表
CREATE TABLE user_addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    receiver VARCHAR(50) NOT NULL,
    phone VARCHAR(11) NOT NULL,
    province VARCHAR(20) NOT NULL,
    city VARCHAR(20) NOT NULL,
    district VARCHAR(20) NOT NULL,
    detail_address VARCHAR(200) NOT NULL,
    is_default TINYINT NOT NULL DEFAULT 0 COMMENT '1-默认地址，0-普通地址',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE (user_id, is_default)
);

-- 5. 订单表
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    address_id INT NOT NULL,
    order_status VARCHAR(20) NOT NULL DEFAULT '待支付' COMMENT '待支付/已支付/已发货/已完成/已取消',
    order_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    remark TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (address_id) REFERENCES user_addresses(address_id)
);

-- 6. 订单详情表
CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 7. 支付表
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(20) NOT NULL COMMENT '微信/支付宝/银行卡',
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_time DATETIME,
    payment_status VARCHAR(20) NOT NULL DEFAULT '未支付' COMMENT '未支付/支付成功/支付失败',
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 插入测试数据
INSERT INTO categories (category_name, parent_id) VALUES
('电子产品', 0),
('服装', 0),
('手机', 1),
('电脑', 1),
('男装', 2),
('女装', 2);

INSERT INTO products (product_name, category_id, price, stock) VALUES
('华为Mate 60 Pro', 3, 6999.00, 100),
('苹果iPhone 15', 3, 5999.00, 80),
('联想拯救者Y9000P', 4, 8999.00, 50),
('戴尔XPS 13', 4, 7999.00, 30),
('优衣库男士T恤', 5, 99.00, 500),
('优衣库女士连衣裙', 6, 199.00, 300);

INSERT INTO users (username, phone, email) VALUES
('张三', '13800138001', 'zhangsan@example.com'),
('李四', '13800138002', 'lisi@example.com'),
('王五', '13800138003', 'wangwu@example.com');

INSERT INTO user_addresses (user_id, receiver, phone, province, city, district, detail_address, is_default) VALUES
(1, '张三', '13800138001', '广东省', '深圳市', '龙华区', '民治街道XX小区1栋101', 1),
(2, '李四', '13800138002', '北京市', '北京市', '海淀区', '中关村大街XX号', 1),
(3, '王五', '13800138003', '上海市', '上海市', '浦东新区', '陆家嘴XX大厦', 1);

INSERT INTO orders (user_id, address_id, order_status, total_amount) VALUES
(1, 1, '已完成', 6999.00),
(1, 1, '已完成', 198.00),
(2, 2, '已支付', 8999.00),
(3, 3, '待支付', 5999.00),
(2, 2, '已完成', 298.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 6999.00),
(2, 5, 2, 99.00),
(3, 3, 1, 8999.00),
(4, 2, 1, 5999.00),
(5, 5, 1, 99.00),
(5, 6, 1, 199.00);

INSERT INTO payments (order_id, payment_method, payment_amount, payment_time, payment_status) VALUES
(1, '微信', 6999.00, '2026-05-01 10:30:00', '支付成功'),
(2, '支付宝', 198.00, '2026-05-02 14:15:00', '支付成功'),
(3, '银行卡', 8999.00, '2026-05-03 09:45:00', '支付成功'),
(5, '微信', 298.00, '2026-05-04 16:20:00', '支付成功');

-- 项目练习题
-- 难度	题号	需求描述
-- 基础	1	查询所有「已完成」订单的订单ID、用户名、下单时间、总金额，按下单时间降序
-- 基础	2	查询每个商品分类的分类名称、商品数量、平均价格、总库存
-- 基础	3	查询用户「张三」的所有收货地址，默认地址排在最前面
-- 基础	4	查询2026年5月1日-5月3日的所有支付记录，显示支付ID、订单ID、支付方式、支付金额
-- 基础	5	查询销量最高的前3个商品，显示商品名称、分类名称、总销量、总销售额
-- 进阶	6	查询每个用户的订单总数、消费总金额、平均客单价、首次下单时间、最后下单时间
-- 进阶	7	查询没有购买过任何电子产品的用户ID、用户名、手机号
-- 进阶	8	查询每个订单的订单ID、商品名称、购买数量、单价、小计金额，按订单ID分组
-- 综合	9	统计2026年5月的每日订单量、每日销售额、每日支付金额，按日期升序
-- 综合	10	查询消费总金额排名前2的用户，以及他们购买过的所有商品名称、分类名称、购买数量

-- 项目参考答案
-- 项目题1
SELECT 
    o.order_id,
    u.username,
    o.order_time,
    o.total_amount
FROM orders o
JOIN users u ON o.user_id = u.user_id
WHERE o.order_status = '已完成'
ORDER BY o.order_time DESC;

-- 项目题2
SELECT 
    c.category_name,
    COUNT(p.product_id) AS 商品数量,
    AVG(p.price) AS 平均价格,
    SUM(p.stock) AS 总库存
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;

-- 项目题3
SELECT *
FROM user_addresses
WHERE user_id = (SELECT user_id FROM users WHERE username = '张三')
ORDER BY is_default DESC;

-- 项目题4
SELECT 
    payment_id,
    order_id,
    payment_method,
    payment_amount
FROM payments
WHERE payment_time BETWEEN '2026-05-01' AND '2026-05-03 23:59:59';

-- 项目题5
SELECT 
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS 总销量,
    SUM(oi.quantity * oi.unit_price) AS 总销售额
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY 总销量 DESC
LIMIT 3;

-- 项目题6
SELECT 
    u.user_id,
    u.username,
    COUNT(DISTINCT o.order_id) AS 订单总数,
    SUM(o.total_amount) AS 消费总金额,
    SUM(o.total_amount) / COUNT(DISTINCT o.order_id) AS 平均客单价,
    MIN(o.order_time) AS 首次下单时间,
    MAX(o.order_time) AS 最后下单时间
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username;

-- 项目题7
SELECT 
    u.user_id,
    u.username,
    u.phone
FROM users u
WHERE u.user_id NOT IN (
    SELECT DISTINCT o.user_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    WHERE c.parent_id = 1 OR c.category_id = 1
);

-- 项目题8
SELECT 
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS 小计金额
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;

-- 项目题9
SELECT 
    DATE(o.order_time) AS 日期,
    COUNT(DISTINCT o.order_id) AS 每日订单量,
    SUM(o.total_amount) AS 每日销售额,
    SUM(p.payment_amount) AS 每日支付金额
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id AND p.payment_status = '支付成功'
WHERE DATE(o.order_time) BETWEEN '2026-05-01' AND '2026-05-31'
GROUP BY DATE(o.order_time)
ORDER BY 日期 ASC;

-- 项目题10
SELECT 
    u.username,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS 购买数量
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE u.user_id IN (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    ORDER BY SUM(total_amount) DESC
    LIMIT 2
)
GROUP BY u.username, p.product_name, c.category_name;
