-- phpMyAdmin SQL Dump
-- version 5.1.3
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost
-- Généré le : mar. 06 déc. 2022 à 15:02
-- Version du serveur : 10.5.12-MariaDB-0+deb11u1
-- Version de PHP : 7.4.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : ``
--

DELIMITER $$
--
-- Procédures
--
CREATE OR REPLACE DEFINER=`zle_barni`@`%` PROCEDURE `USP_match_enable` (IN `id` INT UNSIGNED, IN `bool` TINYINT(1))   BEGIN
	UPDATE T_MATCH_match SET match_enabled = bool WHERE match_id = id;
END$$

CREATE OR REPLACE DEFINER=`zle_barni`@`%` PROCEDURE `USP_new_account` (IN `first_name` VARCHAR(80), IN `last_name` VARCHAR(80), IN `role` CHAR(1), IN `active` TINYINT(1), IN `pseudo` VARCHAR(20), IN `password` TEXT)   BEGIN
	INSERT INTO T_MANAGER_man(man_pseudo, man_pw) VALUES
		(pseudo, password);

	INSERT INTO T_PROFILE_pfl(pfl_first_name, pfl_last_name, pfl_role, pfl_registration_date, pfl_active,  man_id) VALUES
	(
		first_name,
		last_name,
		role,
		CURDATE(),
		active,
		SCOPE_IDENTITY()
	);
END$$

CREATE OR REPLACE DEFINER=`zle_barni`@`%` PROCEDURE `USP_question_enable` (IN `id` INT UNSIGNED, IN `bool` TINYINT(1))   BEGIN
	UPDATE T_QUESTION_qst SET qst_enabled = bool WHERE qst_id = id;
END$$

CREATE OR REPLACE DEFINER=`zle_barni`@`%` PROCEDURE `USP_question_reorder` (IN `id` INT UNSIGNED, IN `new_order` TINYINT UNSIGNED)   BEGIN
	DECLARE _quiz_id INT UNSIGNED;

	SELECT quiz_id INTO _quiz_id FROM T_QUESTION_qst WHERE qst_id = id;

	UPDATE T_QUESTION_qst
	SET qst_order = (
		CASE
			WHEN qst_id = id THEN new_order
			WHEN qst_id != id && qst_order >= new_order THEN qst_order + 1
		END)
	WHERE quiz_id = _quiz_id;
END$$

CREATE OR REPLACE DEFINER=`zle_barni`@`%` PROCEDURE `USP_quiz_enable` (IN `id` INT UNSIGNED, IN `bool` TINYINT(1))   BEGIN
	UPDATE T_QUIZ_quiz SET quiz_enabled = bool WHERE quiz_id = id;
END$$

--
-- Fonctions
--
CREATE OR REPLACE DEFINER=`zle_barni`@`%` FUNCTION `FN_HASH_PW` (`pw` TEXT) RETURNS CHAR(128) CHARSET ascii  BEGIN
	RETURN SHA2(CONCAT(pw, 'sPrCHtXU75e@Fu&wKjvy31&vfz77oJ'), 512);
END$$

CREATE OR REPLACE DEFINER=`zle_barni`@`%` FUNCTION `FN_MATCH_AVERAGE_SCORE` (`_match_id` INT UNSIGNED) RETURNS FLOAT  BEGIN
	DECLARE average_score FLOAT;
    
    SELECT AVG(player_score) INTO average_score
	FROM T_PLAYER_player
	WHERE match_id = _match_id;

	RETURN average_score;
END$$

CREATE OR REPLACE DEFINER=`zle_barni`@`%` FUNCTION `FN_QUESTION_VALID_ANSWERS` (`_qst_id` INT UNSIGNED) RETURNS INT(10) UNSIGNED  BEGIN
	RETURN (
		SELECT COUNT(*)
		FROM T_ANSWER_ans
		WHERE ans_valid = 1 && qst_id = _qst_id
	);
END$$

CREATE OR REPLACE DEFINER=`zle_barni`@`%` FUNCTION `FN_VALID_LOGIN` (`pseudo` VARCHAR(20), `password` TEXT) RETURNS TINYINT(3) UNSIGNED  BEGIN
	DECLARE hashed_pw CHAR(128);
	SET hashed_pw = FN_HASH_PW(password);

	RETURN (
		SELECT (COUNT(*) > 0)
		FROM T_MANAGER_man
		JOIN T_PROFILE_pfl USING(man_id)
		WHERE man_pseudo = pseudo && man_pw = hashed_pw && pfl_active = 1
	);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `T_ANSWER_ans`
--

CREATE TABLE `T_ANSWER_ans` (
  `ans_id` int(10) UNSIGNED NOT NULL,
  `ans_content` varchar(200) NOT NULL,
  `ans_image` varchar(300) DEFAULT NULL,
  `ans_valid` tinyint(3) UNSIGNED NOT NULL,
  `qst_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `T_ANSWER_ans`
--

INSERT INTO `T_ANSWER_ans` (`ans_id`, `ans_content`, `ans_image`, `ans_valid`, `qst_id`) VALUES
(1, 'Poivron', NULL, 0, 1),
(2, 'Laitue', NULL, 1, 1),
(3, 'Curcubitacé', NULL, 0, 1),
(4, 'Tomate', NULL, 0, 1),
(5, 'La pomme de terre noisette', NULL, 0, 2),
(6, 'La pomme de terre primeur', NULL, 1, 2),
(7, 'La pomme de terre grenaille', NULL, 0, 2),
(8, 'Fraise', NULL, 0, 3),
(9, 'Tomate', NULL, 0, 3),
(10, 'Papaye', NULL, 0, 3),
(11, 'Avocat', NULL, 1, 3),
(12, 'Orange', NULL, 1, 4),
(13, 'Banane', NULL, 0, 4),
(14, 'Carambole', NULL, 0, 4),
(15, 'La chlorophylle', NULL, 1, 5),
(16, 'La vitamine A', NULL, 0, 5),
(17, 'Le potassium', NULL, 0, 5),
(18, 'L\'amande', NULL, 0, 6),
(19, 'La fraise', NULL, 0, 6),
(20, 'La rhubarbe', NULL, 1, 6),
(21, 'La cerise', NULL, 0, 6),
(22, 'L\'ananas', NULL, 0, 7),
(23, 'La banane', NULL, 0, 7),
(24, 'La papaye', NULL, 0, 7),
(25, 'La mangue', NULL, 1, 7),
(26, 'Le fruit de la passion', NULL, 1, 8),
(27, 'Le fruit défendu', NULL, 0, 8),
(28, '20%', NULL, 0, 9),
(29, '40%', NULL, 0, 9),
(30, '60%', NULL, 0, 9),
(31, '80%', NULL, 1, 9),
(32, 'La pomme de terre noisette', NULL, 0, 10),
(33, 'La pomme de terre primeur', NULL, 1, 10),
(34, 'La pomme de terre grenaille', NULL, 0, 10),
(35, 'L\'amande', NULL, 0, 11),
(36, 'La fraise', NULL, 0, 11),
(37, 'La rhubarbe', NULL, 1, 11),
(38, 'La cerise', NULL, 0, 11),
(39, '20%', NULL, 0, 12),
(40, '40%', NULL, 0, 9),
(41, '60%', NULL, 0, 12),
(42, '80%', NULL, 1, 12),
(43, 'L\'ananas', NULL, 0, 13),
(44, 'La banane', NULL, 0, 13),
(45, 'La papaye', NULL, 0, 13),
(46, 'La mangue', NULL, 1, 13),
(47, 'La chlorophylle', NULL, 1, 14),
(48, 'La vitamine A', NULL, 0, 14),
(49, 'Le potassium', NULL, 0, 14),
(50, 'Le fruit de la passion', NULL, 1, 15),
(51, 'Le fruit défendu', NULL, 0, 15),
(52, 'Poivron', NULL, 0, 16),
(53, 'Laitue', NULL, 1, 16),
(54, 'Curcubitacé', NULL, 0, 16),
(55, 'Tomate', NULL, 0, 16),
(56, 'Orange', NULL, 1, 17),
(57, 'Banane', NULL, 0, 17),
(58, 'Carambole', NULL, 0, 17),
(59, 'Fraise', NULL, 0, 18),
(60, 'Tomate', NULL, 0, 18),
(61, 'Papaye', NULL, 0, 18),
(62, 'Avocat', NULL, 1, 18),
(63, 'Le melon', NULL, 0, 19),
(64, 'La tomate', NULL, 1, 19),
(65, 'L\'orange', NULL, 0, 19),
(66, 'Du haricot', NULL, 1, 20),
(67, 'Du poivron', NULL, 0, 20),
(68, 'Du concombre', NULL, 0, 20),
(69, 'Une variété de marron', NULL, 0, 21),
(70, 'Une variété de mangue', NULL, 0, 21),
(71, 'Une variété de citron', NULL, 1, 21),
(72, 'Une variété de pomme', NULL, 0, 21),
(73, 'Un concombre', NULL, 1, 22),
(74, 'Un poivron', NULL, 0, 22),
(75, 'Une courgette', NULL, 0, 22),
(76, 'La framboise', NULL, 0, 23),
(77, 'La banane', NULL, 0, 23),
(78, 'L\'ananas', NULL, 0, 23),
(79, 'La grenade', NULL, 1, 23),
(80, 'Indienne', NULL, 1, 24),
(81, 'Méditérannenne', NULL, 0, 24),
(82, 'Du concombre', NULL, 0, 24),
(83, 'Le maroc', NULL, 0, 25),
(84, 'L\'espagne', NULL, 0, 25),
(85, 'La chine', NULL, 1, 25),
(86, 'Les pieds de salicorne sont arrachés', NULL, 0, 26),
(87, 'La salicorne est coupée à sa tête', NULL, 1, 26),
(88, 'La salicorne est coupée à son pied', NULL, 0, 26),
(89, 'Son temps chaud, set et venteux', NULL, 1, 27),
(90, 'Son climat océanique marqué par des pluies abondantes', NULL, 0, 27),
(91, 'Son fort enneigement pendant la saison hivernal', NULL, 0, 27),
(92, 'Finlande', NULL, 0, 28),
(93, 'Iran', NULL, 1, 28),
(94, 'Amérique du Sud', NULL, 0, 28),
(95, 'Un goût de banane', NULL, 0, 29),
(96, 'Un goût de noisette', NULL, 0, 29),
(97, 'Un goût de châtaigne', NULL, 1, 29),
(98, 'Le vibrage', NULL, 1, 30),
(99, 'Le secouage', NULL, 0, 30),
(100, 'Le débranchage', NULL, 0, 30),
(101, 'Deux fois : printemps et été', NULL, 1, 31),
(102, 'Quatre fois : printemps, début d\'été, début d\'automne et fin d\'automne', NULL, 0, 31),
(103, 'Cinq fois : début de printemps, début d\'été, fin d\'été, mi automne et début d\'hiver', NULL, 0, 31),
(104, 'En les ébouillantant', NULL, 0, 32),
(105, 'Avec un économe', NULL, 0, 32),
(106, 'Avec un sac en toile de jute', NULL, 1, 32),
(107, 'Son apport en vitamine D', NULL, 0, 33),
(108, 'Sa teneur en antioxydants', NULL, 1, 33),
(109, 'Son apport en oméga 3', NULL, 0, 33),
(110, 'La peau supérieure du champignon', NULL, 0, 34),
(111, 'Le pied du champignon', NULL, 0, 34),
(112, 'Une base sur laquelle les champignons peuvent se développer', NULL, 1, 34),
(113, 'des semences qui ont exactement le même patrimoine génétique', NULL, 1, 35),
(114, 'des semences qui poussent très vite', NULL, 0, 35),
(115, 'Des semences qui poussent hors sol', NULL, 0, 35),
(116, 'A celle de la topinambour', NULL, 0, 36),
(117, 'A celle du wasabi', NULL, 1, 36),
(118, 'A celle du bambou', NULL, 0, 36),
(119, 'Le maroc', NULL, 0, 37),
(120, 'L\'espagne', NULL, 0, 37),
(121, 'La chine', NULL, 1, 37),
(122, 'Le vibrage', NULL, 1, 38),
(123, 'Le secouage', NULL, 0, 38),
(124, 'Le débranchage', NULL, 0, 38),
(125, 'L\'ananas', NULL, 0, 39),
(126, 'La banane', NULL, 0, 39),
(127, 'La papaye', NULL, 0, 39),
(128, 'La mangue', NULL, 1, 39),
(129, 'Le melon', NULL, 0, 40),
(130, 'La tomate', NULL, 1, 40),
(131, 'L\'orange', NULL, 0, 40),
(132, 'La chlorophylle', NULL, 1, 41),
(133, 'La vitamine A', NULL, 0, 41),
(134, 'Le potassium', NULL, 0, 41),
(135, 'En les ébouillantant', NULL, 0, 42),
(136, 'Avec un économe', NULL, 0, 42),
(137, 'Avec un sac en toile de jute', NULL, 1, 42),
(138, 'La pomme de terre noisette', NULL, 0, 43),
(139, 'La pomme de terre primeur', NULL, 1, 43),
(140, 'La pomme de terre grenaille', NULL, 0, 43),
(141, 'Poivron', NULL, 0, 44),
(142, 'Laitue', NULL, 1, 44),
(143, 'Curcubitacé', NULL, 0, 44),
(144, 'Tomate', NULL, 0, 44),
(145, 'Le fruit de la passion', NULL, 1, 45),
(146, 'Le fruit défendu', NULL, 0, 45),
(147, 'Du haricot', NULL, 1, 46),
(148, 'Du poivron', NULL, 0, 46),
(149, 'Du concombre', NULL, 0, 46),
(150, 'Son apport en vitamine D', NULL, 0, 47),
(151, 'Sa teneur en antioxydants', NULL, 1, 47),
(152, 'Son apport en oméga 3', NULL, 0, 47),
(153, 'Son temps chaud, set et venteux', NULL, 1, 48),
(154, 'Son climat océanique marqué par des pluies abondantes', NULL, 0, 48),
(155, 'Son fort enneigement pendant la saison hivernal', NULL, 0, 48),
(156, 'Un concombre', NULL, 1, 49),
(157, 'Un poivron', NULL, 0, 49),
(158, 'Une courgette', NULL, 0, 49),
(159, 'La peau supérieure du champignon', NULL, 0, 50),
(160, 'Le pied du champignon', NULL, 0, 50),
(161, 'Une base sur laquelle les champignons peuvent se développer', NULL, 1, 50),
(162, 'Finlande', NULL, 0, 51),
(163, 'Iran', NULL, 1, 51),
(164, 'Amérique du Sud', NULL, 0, 51),
(165, 'A celle de la topinambour', NULL, 0, 52),
(166, 'A celle du wasabi', NULL, 1, 52),
(167, 'A celle du bambou', NULL, 0, 52),
(168, 'des semences qui ont exactement le même patrimoine génétique', NULL, 1, 53),
(169, 'des semences qui poussent très vite', NULL, 0, 53),
(170, 'Des semences qui poussent hors sol', NULL, 0, 53),
(171, 'La framboise', NULL, 0, 54),
(172, 'La banane', NULL, 0, 54),
(173, 'L\'ananas', NULL, 0, 54),
(174, 'La grenade', NULL, 1, 54),
(175, 'Fraise', NULL, 0, 55),
(176, 'Tomate', NULL, 0, 55),
(177, 'Papaye', NULL, 0, 55),
(178, 'Avocat', NULL, 1, 55),
(179, 'Un goût de banane', NULL, 0, 56),
(180, 'Un goût de noisette', NULL, 0, 56),
(181, 'Un goût de châtaigne', NULL, 1, 56),
(182, 'Indienne', NULL, 1, 57),
(183, 'Méditérannenne', NULL, 0, 57),
(184, 'Du concombre', NULL, 0, 57),
(185, 'En les ébouillantant', NULL, 0, 58),
(186, 'Avec un économe', NULL, 0, 58),
(187, 'Avec un sac en toile de jute', NULL, 1, 58),
(188, 'Un concombre', NULL, 1, 59),
(189, 'Un poivron', NULL, 0, 59),
(190, 'Une courgette', NULL, 0, 59),
(191, 'Un goût de banane', NULL, 0, 60),
(192, 'Un goût de noisette', NULL, 0, 60),
(193, 'Un goût de châtaigne', NULL, 1, 60),
(194, '20%', NULL, 0, 9),
(195, '40%', NULL, 0, 61),
(196, '60%', NULL, 0, 61),
(197, '80%', NULL, 1, 61),
(198, 'Une variété de marron', NULL, 0, 62),
(199, 'Une variété de mangue', NULL, 0, 62),
(200, 'Une variété de citron', NULL, 1, 62),
(201, 'Une variété de pomme', NULL, 0, 62),
(202, 'Fraise', NULL, 0, 63),
(203, 'Tomate', NULL, 0, 63),
(204, 'Papaye', NULL, 0, 63),
(205, 'Avocat', NULL, 1, 63),
(206, 'La framboise', NULL, 0, 64),
(207, 'La banane', NULL, 0, 64),
(208, 'L\'ananas', NULL, 0, 64),
(209, 'La grenade', NULL, 1, 64),
(210, 'L\'amande', NULL, 0, 65),
(211, 'La fraise', NULL, 0, 65),
(212, 'La rhubarbe', NULL, 1, 65),
(213, 'La cerise', NULL, 0, 65),
(214, 'Le maroc', NULL, 0, 66),
(215, 'L\'espagne', NULL, 0, 66),
(216, 'La chine', NULL, 1, 66),
(217, 'Le fruit de la passion', NULL, 1, 67),
(218, 'Le fruit défendu', NULL, 0, 67),
(219, 'Indienne', NULL, 1, 68),
(220, 'Méditérannenne', NULL, 0, 68),
(221, 'Du concombre', NULL, 0, 68),
(222, 'Le melon', NULL, 0, 69),
(223, 'La tomate', NULL, 1, 69),
(224, 'L\'orange', NULL, 0, 69),
(225, 'La pomme de terre noisette', NULL, 0, 70),
(226, 'La pomme de terre primeur', NULL, 1, 70),
(227, 'La pomme de terre grenaille', NULL, 0, 70),
(228, 'L\'ananas', NULL, 0, 71),
(229, 'La banane', NULL, 0, 71),
(230, 'La papaye', NULL, 0, 71),
(231, 'La mangue', NULL, 1, 71),
(232, 'des semences qui ont exactement le même patrimoine génétique', NULL, 1, 72),
(233, 'des semences qui poussent très vite', NULL, 0, 72),
(234, 'Des semences qui poussent hors sol', NULL, 0, 72),
(235, 'Deux fois : printemps et été', NULL, 1, 73),
(236, 'Quatre fois : printemps, début d\'été, début d\'automne et fin d\'automne', NULL, 0, 73),
(237, 'Cinq fois : début de printemps, début d\'été, fin d\'été, mi automne et début d\'hiver', NULL, 0, 73),
(238, 'A celle de la topinambour', NULL, 0, 74),
(239, 'A celle du wasabi', NULL, 1, 74),
(240, 'A celle du bambou', NULL, 0, 74);

--
-- Déclencheurs `T_ANSWER_ans`
--
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_ANSWER_AFTER_DELETE` AFTER DELETE ON `T_ANSWER_ans` FOR EACH ROW BEGIN
	IF (SELECT COUNT(*) FROM T_QUESTION_qst WHERE qst_id = OLD.qst_id) = 1 || FN_QUESTION_VALID_ANSWERS(OLD.qst_id) = 0 THEN
		UPDATE T_QUESTION_qst SET qst_enabled = 0 WHERE qst_id = OLD.qst_id;
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_ANSWER_AFTER_INSERT` AFTER INSERT ON `T_ANSWER_ans` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_ANSWER_AFTER_UPDATE` AFTER UPDATE ON `T_ANSWER_ans` FOR EACH ROW BEGIN
	IF FN_QUESTION_VALID_ANSWERS(NEW.qst_id) = 0 THEN
		UPDATE T_QUESTION_qst SET qst_enabled = 0 WHERE qst_id = NEW.qst_id;
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_ANSWER_BEFORE_DELETE` BEFORE DELETE ON `T_ANSWER_ans` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_ANSWER_BEFORE_INSERT` BEFORE INSERT ON `T_ANSWER_ans` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_ANSWER_BEFORE_UPDATE` BEFORE UPDATE ON `T_ANSWER_ans` FOR EACH ROW BEGIN END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `T_MANAGER_man`
--

CREATE TABLE `T_MANAGER_man` (
  `man_id` int(10) UNSIGNED NOT NULL,
  `man_pseudo` varchar(20) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `man_pw` char(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `T_MANAGER_man`
--

INSERT INTO `T_MANAGER_man` (`man_id`, `man_pseudo`, `man_pw`) VALUES
(1, 'responsable', '6917481445f718eb9c0b5ade9a27bf77524e8c8b1c38c754225ef41b67e7a67e203bea13808802f144f9d6d63f8287432e7a35662e8e94fe9fea0ebff5e607e0'),
(2, 'nlbeaz', 'd333e44f5f982cf0d6bb7f89e07ac3d34773544819c9ddc51f0d7a321ee4ee81891f704cc3ffdf367ea55b2832209103a967ab6b4e65f037fab2737fe2567234'),
(3, 'thomandjerry', 'c828e1773269535eba0d469c0894e815d622f16502c82fb124cb1c0ed456306fc28967a3a8605ea2fb907cb026c23e4b94e52b5761381d2a3fbee3429f293121'),
(5, 'clairance', '30ba7f652c2026c361392a5ef5fe83c91c46f2cae6428cb81d1f40e340147a7e51a25d9985a787a42e69c6dd293a1ceb083ad403c5d08dd13865eb2617b5cc68'),
(6, 'mengot', '28535d90ea09ff5e21410dc1d272773b71bc36bcbdf444a1d5983c920bf82cda1b3a7e8217cdbdc203a2522de2761ef693b4c304f48bc547fec580aa97f09eaf'),
(7, 'bonnobo', 'dba40e6738fdf638b7ac897090515fc59f1ffca78f93283331135489662e33e7170f2043a77867ebb8c2de59b2b37da1d4730e547f07b462ce71c78496aff0a6'),
(8, 'matracus', '35ccfd2c10facafed1355889b172761f7ba65b7291eeafb6f0d2ec179923af8061be398bd3136b0d689fa6892b3be682feda1ef75ecb13e32b480fe2b2501def'),
(9, 'karmaine', '394f1180c2b2daaba57dd3d9748abea2442f0f7cf53a6da7dccb81afcd85196727b1b334c00eacb68318186d53d7ebe12b35c7d35e75dcde16c31f7dd6b31aad');

--
-- Déclencheurs `T_MANAGER_man`
--
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MANAGER_AFTER_DELETE` AFTER DELETE ON `T_MANAGER_man` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MANAGER_AFTER_INSERT` AFTER INSERT ON `T_MANAGER_man` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MANAGER_AFTER_UPDATE` AFTER UPDATE ON `T_MANAGER_man` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MANAGER_BEFORE_DELETE` BEFORE DELETE ON `T_MANAGER_man` FOR EACH ROW BEGIN
	DELETE FROM T_NEWS_new WHERE man_id = OLD.man_id;
	UPDATE T_QUIZ_quiz SET man_id = 1 WHERE man_id = OLD.man_id;
	UPDATE T_MATCH_match SET man_id = 1 WHERE man_id = OLD.man_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MANAGER_BEFORE_INSERT` BEFORE INSERT ON `T_MANAGER_man` FOR EACH ROW BEGIN
	SET NEW.man_pw := FN_HASH_PW(NEW.man_pw);
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MANAGER_BEFORE_UPDATE` BEFORE UPDATE ON `T_MANAGER_man` FOR EACH ROW BEGIN
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `T_MATCH_match`
--

CREATE TABLE `T_MATCH_match` (
  `match_id` int(10) UNSIGNED NOT NULL,
  `match_title` varchar(200) NOT NULL,
  `match_code` char(8) NOT NULL,
  `match_start_date` datetime DEFAULT NULL,
  `match_end_date` datetime DEFAULT NULL,
  `match_show_answers` tinyint(4) NOT NULL DEFAULT 1,
  `match_enabled` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `quiz_id` int(10) UNSIGNED NOT NULL,
  `man_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `T_MATCH_match`
--

INSERT INTO `T_MATCH_match` (`match_id`, `match_title`, `match_code`, `match_start_date`, `match_end_date`, `match_show_answers`, `match_enabled`, `quiz_id`, `man_id`) VALUES
(1, 'Les pros de l\'agriculture', 'EM5WJ92M', '2022-09-20 00:00:00', '2022-09-20 00:00:00', 0, 0, 1, 3),
(2, 'Les pros de l\'agriculture (Révisions)', 'PMH5AN8S', '2022-09-21 00:00:00', NULL, 1, 1, 2, 3),
(3, 'Petite révision - Sujet B5', 'MAGUSNTI', '2022-10-06 00:00:00', '2022-10-06 00:00:00', 0, 0, 4, 1),
(4, 'Contrôle continue AA1', 'MP1K54JR', '2022-10-07 00:00:00', '2022-10-07 00:00:00', 0, 0, 5, 3),
(5, 'Dure dure la vie de tomate', 'LTGA2SFC', '2022-10-09 00:00:00', '2022-10-09 00:00:00', 1, 0, 3, 6),
(6, 'Préparation au milieu professionnel', 'PMH5AN8S', '2022-10-11 00:00:00', NULL, 1, 1, 8, 5),
(7, 'Dernier test avant examen', 'P82GBH1Y', '2022-10-11 00:00:00', '2023-05-21 00:00:00', 1, 1, 8, 3);

--
-- Déclencheurs `T_MATCH_match`
--
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MATCH_AFTER_DELETE` AFTER DELETE ON `T_MATCH_match` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MATCH_AFTER_INSERT` AFTER INSERT ON `T_MATCH_match` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MATCH_AFTER_UPDATE` AFTER UPDATE ON `T_MATCH_match` FOR EACH ROW BEGIN
	IF ((OLD.match_start_date IS NOT NULL && NEW.match_start_date IS NULL) || NEW.match_start_date >= CURDATE()) && NEW.match_end_date IS NULL
	THEN
		DELETE FROM T_PLAYER_player WHERE match_id = NEW.match_id;
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MATCH_BEFORE_DELETE` BEFORE DELETE ON `T_MATCH_match` FOR EACH ROW BEGIN
	DELETE FROM T_PLAYER_player WHERE match_id = OLD.match_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MATCH_BEFORE_INSERT` BEFORE INSERT ON `T_MATCH_match` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_MATCH_BEFORE_UPDATE` BEFORE UPDATE ON `T_MATCH_match` FOR EACH ROW BEGIN END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `T_NEWS_new`
--

CREATE TABLE `T_NEWS_new` (
  `new_id` int(10) UNSIGNED NOT NULL,
  `new_title` varchar(200) NOT NULL,
  `new_content` varchar(500) NOT NULL,
  `new_date` datetime NOT NULL,
  `man_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `T_NEWS_new`
--

INSERT INTO `T_NEWS_new` (`new_id`, `new_title`, `new_content`, `new_date`, `man_id`) VALUES
(13, 'Le match \"Les pros de l\'agriculture\" viens de se terminer !', 'Merci à tous les participant qui y ont participé du 2022-09-22 au 2022-09-22 !<br/><br/>Liste des participants:<br/>Andrée N., Marcelle G., René d., Virginie B., Jeanne R., Claudine A., Rémy R., Marie C., Jacques T., Jules B., Colette W., Raymond B., Noémi F., Frédéric C., Simone R., Roland W., Édith G., Philippine M., Emmanuelle S., Alex C., Aurore M., Christine H., Aimé G., Matthieu L., Nathalie G., Simone F., Christophe L., Susanne C., Gabriel L., Xavier d.', '2022-09-22 00:00:00', 1),
(14, 'Panne des serveurs', 'Les serveurs sont actuellement en pannes et nous mettons tout en oeuvre pour les rouvrir au plus tôt.<br/>Veuillez nous excuser pour la gêne occasionnée.', '2022-09-22 00:00:00', 1),
(17, 'Le match \"Petite révision - Sujet B5\" viens de se terminer !', 'Merci à tous les participant qui y ont participé du 2022-10-06 au 2022-10-06 !<br/><br/>Liste des participants:<br/>Agathe d., Pierre G., Hortense L., Gabrielle G., Océane G., Jeanne R., Timothée D., Denis G., Benoît B., Antoine L., Thomas d., Philippine M., Margaux L., Virginie d., Nathalie G., Jacques O., Dominique D., Honoré H., Chantal C., Roland P., Honoré D., Jules B., Virginie B., Alex P.', '2022-10-06 00:00:00', 1),
(18, 'Le match \"Contrôle continue AA1\" viens de se terminer !', 'Merci à tous les participant qui y ont participé du 2022-10-07 au 2022-10-07 !<br/><br/>Liste des participants:<br/>Roland W., Isaac R., Antoine B., Marcelle G., Margaret G., Alexandre M., Christiane L., Marie d., Simone R., Caroline H., Antoine L., Célina T., Jules B., Matthieu L., Marie C., Josette d., Claire C., Roland P., Alex C., Alphonse V., Xavier d., Constance D., Honoré H., Rémy R., Frédéric C., Aurore M., Simone F., Honoré D., Édith G., Alex R., Joséphine G., Catherine R., ...', '2022-10-07 00:00:00', 1),
(19, 'Notes au prochain examen', 'Des points bonus seront distribués aux meilleurs élèves qui participeront aux prochains matchs jusqu\'au jour de l\'examen final.', '2022-10-08 00:00:00', 3),
(20, 'Le match \"Dure dure la vie de tomate\" viens de se terminer !', 'Merci à tous les participant qui y ont participé du 2022-10-09 au 2022-10-09 !<br/><br/>Liste des participants:<br/>Andrée N., Marcelle G., René d., Virginie B., Jeanne R., Claudine A., Rémy R., Marie C., Jacques T., Jules B., Colette W., Raymond B., Noémi F., Frédéric C., Simone R., Roland W., Édith G., Philippine M., Emmanuelle S., Alex C.', '2022-10-09 00:00:00', 1);

--
-- Déclencheurs `T_NEWS_new`
--
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_NEWS_AFTER_DELETE` AFTER DELETE ON `T_NEWS_new` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_NEWS_AFTER_INSERT` AFTER INSERT ON `T_NEWS_new` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_NEWS_AFTER_UPDATE` AFTER UPDATE ON `T_NEWS_new` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_NEWS_BEFORE_DELETE` BEFORE DELETE ON `T_NEWS_new` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_NEWS_BEFORE_INSERT` BEFORE INSERT ON `T_NEWS_new` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_NEWS_BEFORE_UPDATE` BEFORE UPDATE ON `T_NEWS_new` FOR EACH ROW BEGIN END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `T_PLAYER_player`
--

CREATE TABLE `T_PLAYER_player` (
  `player_pseudo` varchar(20) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `player_score` float(10) UNSIGNED NOT NULL DEFAULT 0,
  `match_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `T_PLAYER_player`
--

INSERT INTO `T_PLAYER_player` (`player_pseudo`, `player_score`, `match_id`) VALUES
('Adrien F.', 62, 2),
('Adrien F.', 57, 4),
('Adrien F.', 56, 6),
('Adrien F.', 34, 7),
('Adélaïde D.', 21, 2),
('Agathe d.', 72, 2),
('Agathe d.', 70, 3),
('Agathe d.', 75, 6),
('Aimé G.', 15, 1),
('Aimé G.', 41, 6),
('Aimé G.', 89, 7),
('Alex C.', 58, 1),
('Alex C.', 97, 2),
('Alex C.', 96, 4),
('Alex C.', 79, 5),
('Alex P.', 78, 3),
('Alex P.', 49, 4),
('Alex P.', 60, 7),
('Alex R.', 87, 4),
('Alex R.', 57, 7),
('Alexandre M.', 52, 2),
('Alexandre M.', 55, 4),
('Alexandre M.', 73, 6),
('Alphonse V.', 82, 4),
('André G.', 37, 7),
('Andrée N.', 89, 1),
('Andrée N.', 48, 5),
('Anouk d.', 35, 2),
('Anouk d.', 25, 4),
('Antoine B.', 21, 4),
('Antoine B.', 51, 6),
('Antoine L.', 70, 2),
('Antoine L.', 73, 3),
('Antoine L.', 76, 4),
('Antoine L.', 93, 6),
('Antoine L.', 92, 7),
('Aurore M.', 24, 1),
('Aurore M.', 25, 4),
('Aurore M.', 56, 6),
('Aurore P.', 39, 4),
('Aurore P.', 53, 6),
('Benoît B.', 49, 2),
('Benoît B.', 39, 3),
('Benoît B.', 57, 4),
('Benoît B.', 86, 7),
('Bertrand d.', 81, 2),
('Bertrand d.', 47, 4),
('Bertrand d.', 13, 6),
('Caroline H.', 42, 4),
('Caroline H.', 20, 7),
('Catherine R.', 60, 4),
('Catherine R.', 25, 6),
('Chantal C.', 75, 2),
('Chantal C.', 98, 3),
('Chantal C.', 4, 4),
('Christiane L.', 82, 4),
('Christine G.', 65, 4),
('Christine G.', 58, 7),
('Christine H.', 29, 1),
('Christine H.', 90, 4),
('Christophe L.', 41, 1),
('Claire C.', 53, 2),
('Claire C.', 26, 4),
('Claire C.', 78, 7),
('Claude d.', 30, 2),
('Claude d.', 15, 4),
('Claude d.', 28, 6),
('Claude d.', 63, 7),
('Claudine A.', 52, 1),
('Claudine A.', 30, 4),
('Claudine A.', 41, 5),
('Colette W.', 18, 1),
('Colette W.', 57, 4),
('Colette W.', 41, 5),
('Colette W.', 57, 6),
('Constance D.', 15, 4),
('Constance D.', 28, 7),
('Célina T.', 11, 2),
('Célina T.', 21, 4),
('Célina T.', 59, 6),
('Daniel C.', 76, 6),
('Daniel C.', 17, 7),
('Denis C.', 19, 4),
('Denis G.', 74, 2),
('Denis G.', 19, 3),
('Denis G.', 56, 6),
('Dominique D.', 11, 3),
('Dominique D.', 74, 6),
('Emmanuelle S.', 38, 1),
('Emmanuelle S.', 41, 5),
('Frédéric C.', 64, 1),
('Frédéric C.', 10, 4),
('Frédéric C.', 67, 5),
('Frédéric C.', 67, 6),
('Frédérique B.', 71, 2),
('Frédérique B.', 82, 6),
('Gabriel L.', 36, 1),
('Gabriel L.', 21, 2),
('Gabriel L.', 29, 7),
('Gabrielle G.', 68, 3),
('Gabrielle G.', 30, 6),
('Honoré D.', 79, 2),
('Honoré D.', 53, 3),
('Honoré D.', 64, 4),
('Honoré H.', 26, 3),
('Honoré H.', 58, 4),
('Hortense L.', 97, 2),
('Hortense L.', 91, 3),
('Hortense M.', 46, 2),
('Hortense M.', 71, 6),
('Isaac R.', 36, 2),
('Isaac R.', 63, 4),
('Jacques O.', 65, 3),
('Jacques T.', 72, 1),
('Jacques T.', 18, 5),
('Jean G.', 12, 4),
('Jean G.', 19, 7),
('Jeanne R.', 1, 1),
('Jeanne R.', 95, 3),
('Jeanne R.', 59, 5),
('Jeanne R.', 42, 6),
('Josette d.', 15, 4),
('Josette d.', 93, 6),
('Joséphine G.', 39, 2),
('Joséphine G.', 11, 4),
('Joséphine G.', 59, 6),
('Jules B.', 96, 1),
('Jules B.', 92, 2),
('Jules B.', 21, 3),
('Jules B.', 73, 4),
('Jules B.', 70, 5),
('Jules B.', 43, 7),
('Julien M.', 41, 6),
('Julien M.', 11, 7),
('Lorraine F.', 64, 6),
('Louise B.', 51, 2),
('Luc D.', 46, 7),
('Luce R.', 18, 2),
('Luce R.', 46, 6),
('Marcelle G.', 80, 1),
('Marcelle G.', 39, 2),
('Marcelle G.', 19, 4),
('Marcelle G.', 26, 5),
('Marcelle G.', 23, 6),
('Margaret G.', 69, 4),
('Margaux L.', 64, 2),
('Margaux L.', 87, 3),
('Marie C.', 38, 1),
('Marie C.', 41, 4),
('Marie C.', 39, 5),
('Marie d.', 70, 2),
('Marie d.', 39, 4),
('Marie d.', 52, 6),
('Marie d.', 25, 7),
('Martine L.', 90, 2),
('Martine L.', 36, 6),
('Matthieu L.', 19, 1),
('Matthieu L.', 52, 4),
('Matthieu L.', 80, 7),
('Michèle L.', 13, 2),
('Michèle L.', 55, 7),
('Nathalie G.', 65, 1),
('Nathalie G.', 90, 2),
('Nathalie G.', 18, 3),
('Noémi F.', 10, 1),
('Noémi F.', 19, 4),
('Noémi F.', 33, 5),
('Noémi F.', 55, 6),
('Noémi F.', 84, 7),
('Océane G.', 66, 2),
('Océane G.', 52, 3),
('Océane G.', 72, 4),
('POPOLE', 0, 2),
('Patout', 0, 2),
('Paul J.', 10, 2),
('Philippine M.', 58, 1),
('Philippine M.', 73, 2),
('Philippine M.', 11, 3),
('Philippine M.', 32, 5),
('Pierre G.', 44, 3),
('Pierre G.', 64, 6),
('Raymond B.', 88, 1),
('Raymond B.', 58, 2),
('Raymond B.', 51, 5),
('Raymond B.', 67, 6),
('Raymond B.', 18, 7),
('René d.', 76, 1),
('René d.', 38, 2),
('René d.', 42, 4),
('René d.', 24, 5),
('Roland P.', 22, 3),
('Roland P.', 20, 4),
('Roland W.', 37, 1),
('Roland W.', 44, 4),
('Roland W.', 99, 5),
('Roland W.', 71, 7),
('Rémy R.', 22, 1),
('Rémy R.', 21, 4),
('Rémy R.', 87, 5),
('Rémy R.', 60, 7),
('Simone F.', 36, 1),
('Simone F.', 24, 2),
('Simone F.', 13, 4),
('Simone F.', 67, 7),
('Simone R.', 90, 1),
('Simone R.', 62, 2),
('Simone R.', 68, 4),
('Simone R.', 51, 5),
('Susanne C.', 69, 1),
('TEST', 0, 2),
('Thomas L.', 98, 7),
('Thomas d.', 19, 2),
('Thomas d.', 10, 3),
('Thomas d.', 19, 4),
('Thomas d.', 10, 6),
('Timothée D.', 72, 3),
('Timothée D.', 5, 4),
('Timothée D.', 45, 6),
('Timothée D.', 95, 7),
('Timothée L.', 61, 6),
('Victoire L.', 28, 2),
('Victoire L.', 63, 4),
('Virginie B.', 99, 1),
('Virginie B.', 73, 3),
('Virginie B.', 31, 5),
('Virginie d.', 90, 3),
('Xavier V.', 97, 2),
('Xavier V.', 85, 7),
('Xavier d.', 90, 1),
('Xavier d.', 64, 2),
('Xavier d.', 10, 4),
('vava02', 0, 2),
('Édith G.', 72, 1),
('Édith G.', 47, 4),
('Édith G.', 93, 5),
('Édith G.', 47, 6),
('Édith G.', 6, 7),
('Étienne D.', 54, 2);

--
-- Déclencheurs `T_PLAYER_player`
--
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PLAYER_AFTER_DELETE` AFTER DELETE ON `T_PLAYER_player` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PLAYER_AFTER_INSERT` AFTER INSERT ON `T_PLAYER_player` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PLAYER_AFTER_UPDATE` AFTER UPDATE ON `T_PLAYER_player` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PLAYER_BEFORE_DELETE` BEFORE DELETE ON `T_PLAYER_player` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PLAYER_BEFORE_INSERT` BEFORE INSERT ON `T_PLAYER_player` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PLAYER_BEFORE_UPDATE` BEFORE UPDATE ON `T_PLAYER_player` FOR EACH ROW BEGIN END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `T_PROFILE_pfl`
--

CREATE TABLE `T_PROFILE_pfl` (
  `pfl_first_name` varchar(80) NOT NULL,
  `pfl_last_name` varchar(80) NOT NULL,
  `pfl_role` char(1) NOT NULL DEFAULT 'F',
  `pfl_registration_date` date NOT NULL,
  `pfl_active` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `man_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `T_PROFILE_pfl`
--

INSERT INTO `T_PROFILE_pfl` (`pfl_first_name`, `pfl_last_name`, `pfl_role`, `pfl_registration_date`, `pfl_active`, `man_id`) VALUES
('Valérie', 'Marc', 'A', '2022-11-22', 1, 1),
('Nicolas', 'Le Bars', 'A', '2022-11-22', 1, 2),
('Jeremiah', 'Thompson', 'A', '2022-11-22', 1, 3),
('Marc', 'Leclercq', 'F', '2022-11-22', 1, 5),
('Margot', 'Mendes', 'F', '2022-11-22', 1, 6),
('Agnès', 'Bonneau', 'F', '2022-11-22', 0, 7),
('Marius', 'Brebion', 'F', '2022-11-22', 1, 8),
('Elsa', 'Gautier', 'F', '2022-11-22', 0, 9);

--
-- Déclencheurs `T_PROFILE_pfl`
--
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PROFILE_AFTER_DELETE` AFTER DELETE ON `T_PROFILE_pfl` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PROFILE_AFTER_INSERT` AFTER INSERT ON `T_PROFILE_pfl` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PROFILE_AFTER_UPDATE` AFTER UPDATE ON `T_PROFILE_pfl` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PROFILE_BEFORE_DELETE` BEFORE DELETE ON `T_PROFILE_pfl` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PROFILE_BEFORE_INSERT` BEFORE INSERT ON `T_PROFILE_pfl` FOR EACH ROW BEGIN
	SET NEW.pfl_registration_date = CURDATE();
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_PROFILE_BEFORE_UPDATE` BEFORE UPDATE ON `T_PROFILE_pfl` FOR EACH ROW BEGIN END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `T_QUESTION_qst`
--

CREATE TABLE `T_QUESTION_qst` (
  `qst_id` int(10) UNSIGNED NOT NULL,
  `qst_content` varchar(200) NOT NULL,
  `qst_image` varchar(300) DEFAULT NULL,
  `qst_order` tinyint(3) UNSIGNED NOT NULL,
  `qst_enabled` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `quiz_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `T_QUESTION_qst`
--

INSERT INTO `T_QUESTION_qst` (`qst_id`, `qst_content`, `qst_image`, `qst_order`, `qst_enabled`, `quiz_id`) VALUES
(1, 'Je peux m\'appeler \"scarole, iceberg, romaine, roquette\"... Je suis une variété de... ?', NULL, 0, 1, 1),
(2, 'Quelle pomme de terre ne pousse qu\'au printemps ?', NULL, 1, 1, 1),
(3, 'À base de quel fruit confectionne-t-on un guacamole ?', NULL, 2, 1, 1),
(4, 'Le roman d\'Antony Burgess adapté au cinéma par Kubrick est : \"XXXX mécanique\"', NULL, 3, 0, 1),
(5, 'Qu\'est ce qui donne la couleur verte aux fruits et légumes ?', NULL, 4, 1, 1),
(6, 'Lequel de ces fruits de printemps a des feuilles toxiques ?', NULL, 5, 1, 1),
(7, 'Quel fruit est sacré pour les Hindous et symbole d\'amour et de fortune ?', NULL, 6, 1, 1),
(8, 'Quel est l\'autre nom du maracudja ?', NULL, 7, 1, 1),
(9, 'La pomme de terre est composé d’eau à... ?', NULL, 8, 1, 1),
(10, 'Quelle pomme de terre ne pousse qu\'au printemps ?', NULL, 0, 1, 2),
(11, 'Lequel de ces fruits de printemps a des feuilles toxiques ?', NULL, 1, 1, 2),
(12, 'La pomme de terre est composé d’eau à... ?', NULL, 2, 1, 2),
(13, 'Quel fruit est sacré pour les Hindous et symbole d\'amour et de fortune ?', NULL, 3, 1, 2),
(14, 'Qu\'est ce qui donne la couleur verte aux fruits et légumes ?', NULL, 4, 1, 2),
(15, 'Quel est l\'autre nom du maracudja ?', NULL, 5, 1, 2),
(16, 'Je peux m\'appeler \"scarole, iceberg, romaine, roquette\"... Je suis une variété de... ?', NULL, 6, 1, 2),
(17, 'Le roman d\'Antony Burgess adapté au cinéma par Kubrick est : \"XXXX mécanique\"', NULL, 7, 1, 2),
(18, 'À base de quel fruit confectionne-t-on un guacamole ?', NULL, 8, 1, 2),
(19, 'Quel est l\'autre nom de la pomme d\'amour ?', NULL, 0, 1, 3),
(20, 'Il est vert, rouge ou blanc de qui s\'agit-il ?', NULL, 1, 1, 3),
(21, 'Qu\'est-ce-qu\'une \"Main de buddah\" ?', NULL, 2, 1, 3),
(22, 'Le cornichon est ?', NULL, 3, 1, 3),
(23, 'Quel fruit est surnommé le fruit des dieux ?', NULL, 4, 1, 3),
(24, 'Le citron est un fruit d\'origine ?', NULL, 5, 1, 3),
(25, 'Quel pays est le premier producteur de tomate ?', NULL, 6, 1, 3),
(26, 'Comment la salicorne est-elle cueillie ?', NULL, 0, 1, 4),
(27, 'Qu\'est-ce qui fait que la région de Saint-Flour se prête tout particulièrement à la culture de la lentille blonde ?', NULL, 1, 1, 4),
(28, 'La cerise Noire de Meched vient de ?', NULL, 2, 1, 4),
(29, 'Quel goût a la courge du marais breton vendéen ?', NULL, 3, 1, 4),
(30, 'Lors de la récolte des noix, comment se nomme l\'étape où l’on fait tomber ces fruits secs à terre pour les ramasser ?', NULL, 4, 1, 4),
(31, 'Combien de fois dans l\'année le champ de rhubarbe est-il récolté ? ', NULL, 5, 1, 4),
(32, 'Comment peut-on éplucher facilement et simplement les Bonnottes ?', NULL, 6, 1, 4),
(33, 'Quelle est la qualité nutritive essentielle du bleuet ?', NULL, 7, 1, 4),
(34, 'Qu’est-ce qu\'un substrat ?', NULL, 8, 1, 4),
(35, 'Que sont des semences hybrides F1 du petit pois violet ?', NULL, 9, 1, 4),
(36, 'A quelle racine le raifort est-il souvent comparé ? ', NULL, 10, 1, 4),
(37, 'Quel pays est le premier producteur de tomate ?', NULL, 0, 1, 5),
(38, 'Lors de la récolte des noix, comment se nomme l\'étape où l’on fait tomber ces fruits secs à terre pour les ramasser ?', NULL, 1, 1, 5),
(39, 'Quel fruit est sacré pour les Hindous et symbole d\'amour et de fortune ?', NULL, 2, 1, 5),
(40, 'Quel est l\'autre nom de la pomme d\'amour ?', NULL, 3, 1, 5),
(41, 'Qu\'est ce qui donne la couleur verte aux fruits et légumes ?', NULL, 4, 1, 5),
(42, 'Comment peut-on éplucher facilement et simplement les Bonnottes ?', NULL, 5, 1, 5),
(43, 'Quelle pomme de terre ne pousse qu\'au printemps ?', NULL, 6, 1, 5),
(44, 'Je peux m\'appeler \"scarole, iceberg, romaine, roquette\"... Je suis une variété de... ?', NULL, 7, 1, 5),
(45, 'Quel est l\'autre nom du maracudja ?', NULL, 8, 1, 5),
(46, 'Il est vert, rouge ou blanc de qui s\'agit-il ?', NULL, 9, 1, 5),
(47, 'Quelle est la qualité nutritive essentielle du bleuet ?', NULL, 10, 1, 5),
(48, 'Qu\'est-ce qui fait que la région de Saint-Flour se prête tout particulièrement à la culture de la lentille blonde ?', NULL, 11, 1, 5),
(49, 'Le cornichon est ?', NULL, 0, 1, 6),
(50, 'Qu’est-ce qu\'un substrat ?', NULL, 1, 1, 6),
(51, 'La cerise Noire de Meched vient de ?', NULL, 2, 1, 6),
(52, 'A quelle racine le raifort est-il souvent comparé ? ', NULL, 3, 1, 6),
(53, 'Que sont des semences hybrides F1 du petit pois violet ?', NULL, 4, 0, 6),
(54, 'Quel fruit est surnommé le fruit des dieux ?', NULL, 5, 1, 6),
(55, 'À base de quel fruit confectionne-t-on un guacamole ?', NULL, 6, 0, 6),
(56, 'Quel goût a la courge du marais breton vendéen ?', NULL, 7, 1, 6),
(57, 'Le citron est un fruit d\'origine ?', NULL, 8, 1, 6),
(58, 'Comment peut-on éplucher facilement et simplement les Bonnottes ?', NULL, 0, 1, 7),
(59, 'Le cornichon est ?', NULL, 1, 1, 7),
(60, 'Quel goût a la courge du marais breton vendéen ?', NULL, 2, 0, 7),
(61, 'La pomme de terre est composé d’eau à... ?', NULL, 3, 1, 7),
(62, 'Qu\'est-ce-qu\'une \"Main de buddah\" ?', NULL, 4, 1, 7),
(63, 'À base de quel fruit confectionne-t-on un guacamole ?', NULL, 5, 1, 7),
(64, 'Quel fruit est surnommé le fruit des dieux ?', NULL, 6, 1, 7),
(65, 'Lequel de ces fruits de printemps a des feuilles toxiques ?', NULL, 0, 1, 8),
(66, 'Quel pays est le premier producteur de tomate ?', NULL, 1, 1, 8),
(67, 'Quel est l\'autre nom du maracudja ?', NULL, 2, 0, 8),
(68, 'Le citron est un fruit d\'origine ?', NULL, 3, 0, 8),
(69, 'Quel est l\'autre nom de la pomme d\'amour ?', NULL, 4, 1, 8),
(70, 'Quelle pomme de terre ne pousse qu\'au printemps ?', NULL, 5, 1, 8),
(71, 'Quel fruit est sacré pour les Hindous et symbole d\'amour et de fortune ?', NULL, 6, 1, 8),
(72, 'Que sont des semences hybrides F1 du petit pois violet ?', NULL, 7, 1, 8),
(73, 'Combien de fois dans l\'année le champ de rhubarbe est-il récolté ? ', NULL, 8, 1, 8),
(74, 'A quelle racine le raifort est-il souvent comparé ? ', NULL, 9, 1, 8);

--
-- Déclencheurs `T_QUESTION_qst`
--
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUESTION_AFTER_DELETE` AFTER DELETE ON `T_QUESTION_qst` FOR EACH ROW BEGIN
	DECLARE title TEXT;
	DECLARE nb_qst_remaining INT UNSIGNED;
	DECLARE nb_matches_related INT UNSIGNED;
	DECLARE matches_related TEXT;
	DECLARE nb_man_concerned INT UNSIGNED;
	DECLARE man_concerned TEXT;


	SET title = CONCAT('Modification du quiz ', OLD.quiz_id);
	SELECT COUNT(*) INTO nb_qst_remaining FROM T_QUESTION_qst WHERE quiz_id = OLD.quiz_id;
	SELECT
		COUNT(match_id),
		GROUP_CONCAT(match_id),
		COUNT(DISTINCT man_id),
		GROUP_CONCAT(DISTINCT man_pseudo)
		INTO nb_matches_related, matches_related, nb_man_concerned, man_concerned
		FROM T_MATCH_match
		JOIN T_MANAGER_man USING(man_id)
		WHERE quiz_id = OLD.quiz_id;

	DELETE FROM T_NEWS_new WHERE new_title = title;
	INSERT INTO T_NEWS_new(new_title, new_content, new_date, man_id) VALUES
    (
        title,
        CONCAT(
        	CASE
        		WHEN nb_qst_remaining > 1 THEN CONCAT('Suppression d''une question, ', nb_qst_remaining, ' restantes.')
        		WHEN nb_qst_remaining = 1 THEN 'ATTENTION, plus qu’une question !'
        		ELSE 'QUIZ VIDE !'
        	END,
        	'\n\n',
        	CASE
        		WHEN nb_matches_related > 1 THEN CONCAT(
        				'Matchs associés: ', matches_related, '\n',
        				CASE
        					WHEN nb_man_concerned > 1 THEN CONCAT('Formateurs concernés: ', man_concerned)
        					ELSE CONCAT('Formateur concerné: ', man_concerned)
        				END
        			)
        		WHEN nb_matches_related = 1 THEN CONCAT(
        				'Match associé: ', matches_related, '\n',
        				CASE
        					WHEN nb_man_concerned > 1 THEN CONCAT('Formateurs concernés: ', man_concerned)
        					ELSE CONCAT('Formateur concerné: ', man_concerned)
        				END
        			)
        		ELSE 'Aucun match associé à ce quiz pour l’instant !'
        	END
        ),
        CURDATE(),
        1
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUESTION_AFTER_INSERT` AFTER INSERT ON `T_QUESTION_qst` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUESTION_AFTER_UPDATE` AFTER UPDATE ON `T_QUESTION_qst` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUESTION_BEFORE_DELETE` BEFORE DELETE ON `T_QUESTION_qst` FOR EACH ROW BEGIN
	DELETE FROM T_ANSWER_ans WHERE qst_id = OLD.qst_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUESTION_BEFORE_INSERT` BEFORE INSERT ON `T_QUESTION_qst` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUESTION_BEFORE_UPDATE` BEFORE UPDATE ON `T_QUESTION_qst` FOR EACH ROW BEGIN
	#IF OLD.qst_order != NEW.qst_order && (SELECT COUNT(*) FROM T_QUESTION_qst WHERE qst_order = NEW.qst_order) > 0 THEN
	#	UPDATE T_QUESTION_qst
	#	SET qst_order = qst_order + 1
	#	WHERE qst_order >= NEW.qst_order;
	#END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `T_QUIZ_quiz`
--

CREATE TABLE `T_QUIZ_quiz` (
  `quiz_id` int(10) UNSIGNED NOT NULL,
  `quiz_title` varchar(200) NOT NULL,
  `quiz_image` varchar(300) NOT NULL,
  `quiz_enabled` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `man_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `T_QUIZ_quiz`
--

INSERT INTO `T_QUIZ_quiz` (`quiz_id`, `quiz_title`, `quiz_image`, `quiz_enabled`, `man_id`) VALUES
(1, 'Connaissez vous vraiment ce que vous mangez ?', '0.jpg', 1, 3),
(2, 'Connaissez vous vraiment ce que vous mangez ? (Révisions)', '0.jpg', 1, 3),
(3, 'PHY1', '1.jpg', 1, 6),
(4, 'La terre est notre amie', '2.jpg', 0, 1),
(5, 'SVT1', '3.jpg', 0, 3),
(6, 'Du beurre dans les épinards', '4.jpg', 1, 9),
(7, 'test', '5.jpg', 1, 7),
(8, 'Recap', '6.jpg', 1, 3);

--
-- Déclencheurs `T_QUIZ_quiz`
--
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUIZ_AFTER_DELETE` AFTER DELETE ON `T_QUIZ_quiz` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUIZ_AFTER_INSERT` AFTER INSERT ON `T_QUIZ_quiz` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUIZ_AFTER_UPDATE` AFTER UPDATE ON `T_QUIZ_quiz` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUIZ_BEFORE_DELETE` BEFORE DELETE ON `T_QUIZ_quiz` FOR EACH ROW BEGIN
	DELETE FROM T_QUESTION_qst WHERE quiz_id = OLD.quiz_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUIZ_BEFORE_INSERT` BEFORE INSERT ON `T_QUIZ_quiz` FOR EACH ROW BEGIN END
$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE TRIGGER `TR_QUIZ_BEFORE_UPDATE` BEFORE UPDATE ON `T_QUIZ_quiz` FOR EACH ROW BEGIN END
$$
DELIMITER ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `T_ANSWER_ans`
--
ALTER TABLE `T_ANSWER_ans`
  ADD PRIMARY KEY (`ans_id`),
  ADD KEY `fk_T_REPONSE_REP_T_QUESTION_QST1_idx` (`qst_id`);

--
-- Index pour la table `T_MANAGER_man`
--
ALTER TABLE `T_MANAGER_man`
  ADD PRIMARY KEY (`man_id`);

--
-- Index pour la table `T_MATCH_match`
--
ALTER TABLE `T_MATCH_match`
  ADD PRIMARY KEY (`match_id`),
  ADD KEY `fk_T_MATCH_MATCH_T_QUIZ_QUIZ1_idx` (`quiz_id`),
  ADD KEY `fk_T_MATCH_match_T_MANAGER_man1_idx` (`man_id`);

--
-- Index pour la table `T_NEWS_new`
--
ALTER TABLE `T_NEWS_new`
  ADD PRIMARY KEY (`new_id`),
  ADD KEY `fk_T_ACTUALITE_actu_T_MANAGER_man1_idx` (`man_id`);

--
-- Index pour la table `T_PLAYER_player`
--
ALTER TABLE `T_PLAYER_player`
  ADD PRIMARY KEY (`player_pseudo`,`match_id`),
  ADD KEY `fk_T_JOUEUR_jou_T_MATCH_match1_idx` (`match_id`);

--
-- Index pour la table `T_PROFILE_pfl`
--
ALTER TABLE `T_PROFILE_pfl`
  ADD PRIMARY KEY (`man_id`);

--
-- Index pour la table `T_QUESTION_qst`
--
ALTER TABLE `T_QUESTION_qst`
  ADD PRIMARY KEY (`qst_id`),
  ADD KEY `fk_T_QUESTION_QST_T_QUIZ_QUIZ1_idx` (`quiz_id`);

--
-- Index pour la table `T_QUIZ_quiz`
--
ALTER TABLE `T_QUIZ_quiz`
  ADD PRIMARY KEY (`quiz_id`),
  ADD KEY `fk_T_QUIZ_quiz_T_MANAGER_man1_idx` (`man_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `T_ANSWER_ans`
--
ALTER TABLE `T_ANSWER_ans`
  MODIFY `ans_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=241;

--
-- AUTO_INCREMENT pour la table `T_MANAGER_man`
--
ALTER TABLE `T_MANAGER_man`
  MODIFY `man_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `T_MATCH_match`
--
ALTER TABLE `T_MATCH_match`
  MODIFY `match_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `T_NEWS_new`
--
ALTER TABLE `T_NEWS_new`
  MODIFY `new_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT pour la table `T_QUESTION_qst`
--
ALTER TABLE `T_QUESTION_qst`
  MODIFY `qst_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT pour la table `T_QUIZ_quiz`
--
ALTER TABLE `T_QUIZ_quiz`
  MODIFY `quiz_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `T_ANSWER_ans`
--
ALTER TABLE `T_ANSWER_ans`
  ADD CONSTRAINT `fk_T_REPONSE_REP_T_QUESTION_QST1` FOREIGN KEY (`qst_id`) REFERENCES `T_QUESTION_qst` (`qst_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `T_MATCH_match`
--
ALTER TABLE `T_MATCH_match`
  ADD CONSTRAINT `fk_T_MATCH_MATCH_T_QUIZ_QUIZ1` FOREIGN KEY (`quiz_id`) REFERENCES `T_QUIZ_quiz` (`quiz_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_T_MATCH_match_T_MANAGER_man1` FOREIGN KEY (`man_id`) REFERENCES `T_MANAGER_man` (`man_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `T_NEWS_new`
--
ALTER TABLE `T_NEWS_new`
  ADD CONSTRAINT `fk_T_ACTUALITE_actu_T_MANAGER_man1` FOREIGN KEY (`man_id`) REFERENCES `T_MANAGER_man` (`man_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `T_PLAYER_player`
--
ALTER TABLE `T_PLAYER_player`
  ADD CONSTRAINT `fk_T_JOUEUR_jou_T_MATCH_match1` FOREIGN KEY (`match_id`) REFERENCES `T_MATCH_match` (`match_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `T_PROFILE_pfl`
--
ALTER TABLE `T_PROFILE_pfl`
  ADD CONSTRAINT `fk_T_PROFILE_pfl_T_MANAGER_man1` FOREIGN KEY (`man_id`) REFERENCES `T_MANAGER_man` (`man_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `T_QUESTION_qst`
--
ALTER TABLE `T_QUESTION_qst`
  ADD CONSTRAINT `fk_T_QUESTION_QST_T_QUIZ_QUIZ1` FOREIGN KEY (`quiz_id`) REFERENCES `T_QUIZ_quiz` (`quiz_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `T_QUIZ_quiz`
--
ALTER TABLE `T_QUIZ_quiz`
  ADD CONSTRAINT `fk_T_QUIZ_quiz_T_MANAGER_man1` FOREIGN KEY (`man_id`) REFERENCES `T_MANAGER_man` (`man_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
