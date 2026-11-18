import '../models/word_model.dart';

/// Small offline dictionary for the debug scenarios: at least one word per
/// letter (A–Z), and varied themes so that the 3 daily candidates differ.
abstract class FakeWords {
  static WordModel _w(int id, String name, String type, String theme, String definition) =>
      WordModel(
        id: id,
        name: name,
        gender: 'n.',
        type: type,
        theme: theme,
        definition: definition,
      );

  static final List<WordModel> all = [
    _w(1, 'abaque', 'nom masculin', 'Mathématiques', 'Tableau ou boulier servant à faire des calculs.'),
    _w(2, 'badiane', 'nom féminin', 'Botanique', "Fruit étoilé d'un arbuste d'Asie, au goût anisé."),
    _w(3, 'cabestan', 'nom masculin', 'Marine', 'Treuil à axe vertical servant à haler les câbles.'),
    _w(4, 'dédale', 'nom masculin', 'Architecture', "Lieu où l'on s'égare tant les chemins sont enchevêtrés."),
    _w(5, 'éphémère', 'nom masculin', 'Zoologie', "Insecte dont l'adulte ne vit que quelques heures."),
    _w(6, 'falbala', 'nom masculin', 'Habillement', "Bande d'étoffe plissée ornant le bas d'une robe."),
    _w(7, 'gabion', 'nom masculin', 'Génie civil', 'Cage de grillage remplie de pierres, utilisée en soutènement.'),
    _w(8, 'hapax', 'nom masculin', 'Linguistique', "Mot dont on ne connaît qu'un seul emploi dans un corpus."),
    _w(9, 'iconoclaste', 'nom masculin', 'Religion', 'Personne qui détruit les images saintes.'),
    _w(10, 'jabot', 'nom masculin', 'Ornithologie', "Poche de l'œsophage des oiseaux où séjourne la nourriture."),
    _w(11, 'kaléidoscope', 'nom masculin', 'Optique', 'Tube à miroirs où des fragments colorés forment des motifs.'),
    _w(12, 'lapalissade', 'nom féminin', 'Rhétorique', "Affirmation d'une évidence naïve."),
    _w(13, 'madrépore', 'nom masculin', 'Océanographie', 'Corail des mers chaudes qui forme des récifs.'),
    _w(14, 'nadir', 'nom masculin', 'Astronomie', 'Point du ciel situé à la verticale sous l\'observateur.'),
    _w(15, 'obole', 'nom féminin', 'Histoire', 'Petite pièce de monnaie grecque ; modeste offrande.'),
    _w(16, 'palimpseste', 'nom masculin', 'Paléographie', 'Manuscrit gratté pour y écrire un nouveau texte.'),
    _w(17, 'quolibet', 'nom masculin', 'Langage familier', "Plaisanterie moqueuse lancée à quelqu'un."),
    _w(18, 'rhizome', 'nom masculin', 'Botanique', 'Tige souterraine qui produit racines et pousses.'),
    _w(19, 'sérendipité', 'nom féminin', 'Sciences', 'Découverte heureuse faite par hasard.'),
    _w(20, 'tamis', 'nom masculin', 'Cuisine', 'Ustensile à toile fine pour passer la farine.'),
    _w(21, 'ubac', 'nom masculin', 'Géographie', "Versant d'une montagne exposé à l'ombre."),
    _w(22, 'vergeture', 'nom féminin', 'Médecine', 'Strie de la peau due à une distension.'),
    _w(23, 'wapiti', 'nom masculin', 'Mammalogie', "Grand cerf d'Amérique du Nord."),
    _w(24, 'xylophage', 'nom masculin', 'Entomologie', 'Insecte qui se nourrit de bois.'),
    _w(25, 'yole', 'nom féminin', 'Nautisme', 'Embarcation légère et étroite, à avirons.'),
    _w(26, 'zéphyr', 'nom masculin', 'Météorologie', 'Vent doux et agréable.'),
    _w(27, 'alambic', 'nom masculin', 'Chimie', 'Appareil servant à distiller.'),
    _w(28, 'brimborion', 'nom masculin', 'Vie quotidienne', 'Objet de peu de valeur.'),
    _w(29, 'chimère', 'nom féminin', 'Mythologie', 'Monstre fabuleux ; projet irréalisable.'),
    _w(30, 'dithyrambe', 'nom masculin', 'Littérature', 'Éloge enthousiaste, souvent excessif.'),
    _w(31, 'escarcelle', 'nom féminin', 'Moyen Âge', 'Grande bourse suspendue à la ceinture.'),
    _w(32, 'fanfreluche', 'nom féminin', 'Couture', 'Ornement léger de toilette.'),
    _w(33, 'galimatias', 'nom masculin', 'Langage', 'Discours embrouillé et incompréhensible.'),
    _w(34, 'hiéroglyphe', 'nom masculin', 'Écriture', 'Signe de l\'écriture des anciens Égyptiens.'),
    _w(35, 'incunable', 'nom masculin', 'Imprimerie', 'Livre imprimé avant 1501.'),
    _w(36, 'jacquerie', 'nom féminin', 'Politique', 'Révolte paysanne.'),
    _w(37, 'lucarne', 'nom féminin', 'Construction', 'Petite fenêtre aménagée dans un toit.'),
    _w(38, 'mansarde', 'nom féminin', 'Logement', 'Pièce sous les combles au plafond incliné.'),
    _w(39, 'nyctalope', 'nom masculin', 'Biologie', "Être qui voit dans l'obscurité."),
    _w(40, 'oriflamme', 'nom féminin', 'Héraldique', "Bannière d'apparat."),
    _w(41, 'pangolin', 'nom masculin', 'Faune', 'Mammifère couvert d\'écailles.'),
    _w(42, 'ricochet', 'nom masculin', 'Physique', "Rebond d'un objet sur une surface."),
    _w(43, 'saltimbanque', 'nom masculin', 'Spectacle', 'Artiste de foire.'),
    _w(44, 'tohu-bohu', 'nom masculin', 'Expression', 'Grand désordre bruyant.'),
    _w(45, 'vespasienne', 'nom féminin', 'Urbanisme', 'Urinoir public.'),
    _w(46, 'kayak', 'nom masculin', 'Sport', 'Embarcation légère manœuvrée à la pagaie double.'),
    _w(47, 'quinquet', 'nom masculin', 'Éclairage', 'Ancienne lampe à huile à double courant d\'air.'),
    _w(48, 'ukulélé', 'nom masculin', 'Musique', 'Petite guitare à quatre cordes.'),
    _w(49, 'yourte', 'nom féminin', 'Habitat', 'Tente circulaire des nomades d\'Asie centrale.'),
    _w(50, 'zibeline', 'nom féminin', 'Fourrure', 'Martre de Sibérie à la fourrure précieuse.'),
  ];

  static WordModel named(String name) => all.firstWhere((word) => word.name == name);
}
