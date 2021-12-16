(ns main)

(defn part1 [moves]
  (let [min_amount (nth moves (quot (count moves) 2))]
    (println "Part 1:" (reduce (fn [sum move]
      (+ sum (Math/abs (- move min_amount)))
    ) 0 moves))))

(defn part2 [moves]
  (let [lowest_dist (+ 0 (quot (reduce (fn [sum move] (+ sum move)) 0 moves) (count moves)))
        do_part2 (fn [lowest_dist] (biginteger (quot (reduce (fn [sum move]
      (let [num (Math/abs (- move lowest_dist))]
        (+ sum (* num (+ num 1))))
    ) (bigint 0) moves) 2)))]
    (printf "Part 2: %d\n" (min (do_part2 lowest_dist) (do_part2 (+ lowest_dist 1))))))

(defn run [opts]
  (let [lines (map read-string (clojure.string/split (slurp *in*) #","))
        sorted (sort lines)]
    (part1 sorted)
    (part2 sorted)))


;; (defn run [opts]
;;   (let [lines (map read-string (clojure.string/split (slurp *in*) #","))]
;;     (let [sorted (sort lines)]
;;       (part1 sorted)
;;       (part2 sorted))))