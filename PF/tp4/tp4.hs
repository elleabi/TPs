-- Fabre Loïc - Lambin Abigaïl - TP4

module Tp4 where
import Test.QuickCheck
 
-- 1
data Arbre coul val = Noeud { valeur :: val
                              , couleur :: coul
                              , gauche :: Arbre coul val
                              , droit  :: Arbre coul val }
                    | Feuille
                      deriving Show

-- 2
mapArbre :: (a -> b) -> Arbre c a -> Arbre c b
mapArbre _ Feuille  = Feuille
mapArbre f (Noeud val coul g d) =
 Noeud (f val) coul (mapArbre f g) (mapArbre f d)

foldArbre :: (a -> b -> b -> b) -> b -> Arbre c a -> b
foldArbre _ v Feuille = v 
foldArbre f v (Noeud val _ g d) = f val (foldArbre f v g) (foldArbre f v d)

-- 3
hauteur :: Arbre c a -> Int
hauteur Feuille  = 0
hauteur (Noeud _ _ g d) = 1 + (max (hauteur g) (hauteur d))

taille :: Arbre c a -> Int
taille Feuille  = 0
taille (Noeud _ _ g d) = 1 + (taille g) + (taille d)

arbTest = Noeud 14 "vert" (Noeud 18 "vert" (Noeud 42 "vert" Feuille Feuille) Feuille) (Noeud 51 "vert" Feuille Feuille)

hauteur' :: Arbre c a -> Int
hauteur' = foldArbre (\_ y z -> 1 + max y z) 0

taille' :: Arbre c a -> Int
taille' = foldArbre (\_ y z -> 1 + y + z) 0

-- 4
peigneGauche :: [(c,a)] -> Arbre c a
peigneGauche [] = Feuille
peigneGauche ((coul,v):xs) = Noeud v coul (peigneGauche xs) Feuille

-- 5
prop_hauteurPeigne xs = length xs == hauteur (peigneGauche xs)

-- 6
prop_taillePeigne xs = length xs == taille (peigneGauche xs)
-- prop_map

-- 7
estComplet :: Arbre c a -> Bool
estComplet Feuille = True
estComplet (Noeud _ _ g d) = ((taille g) == (taille d)) && (estComplet g) && (estComplet d)


arbCompletTest  = Noeud 18 "vert" Feuille Feuille
arbCompletTest2 = Noeud 14 "vert" (Noeud 18 "vert" Feuille Feuille) (Noeud 51 "vert" Feuille Feuille)

estComplet' :: Arbre c a -> Bool
estComplet' arbre = fst (foldArbre (\ _ (jeSuisComplet, h_g) (jeSuisComplet', h_d) -> (h_g == h_d && jeSuisComplet && jeSuisComplet', fromInteger (h_g + 1) )) (True, 0) arbre)

arbPasCompletTest = Noeud 14 "vert" (Noeud 18 "vert" (Noeud 182 "vert" Feuille Feuille) Feuille) (Noeud 51 "vert"(Noeud 512 "vert" Feuille Feuille)  Feuille)

-- 8
-- Il y a 2 peignes à gauche complets, quand l'arbre est une Feuille et quand l'arbre a 1 Noeud
prop_estCompletPeigne [] = estComplet (peigneGauche [])
prop_estCompletPeigne [x] = estComplet (peigneGauche [x])
prop_estCompletPeigne xs = not (estComplet (peigneGauche xs))

-- 9
complet :: Int -> [(c, a)] -> Arbre c a
complet 0 [] = Feuille
complet 1 [(coul, val)] = (Noeud val coul Feuille Feuille)
complet n xs = Noeud val coul g d 
  where g          = (complet (n-1) (take (n-1) xs))
        d          = (complet (n-1) (drop (n) xs))
        (coul,val) = xs !! (n-1)
